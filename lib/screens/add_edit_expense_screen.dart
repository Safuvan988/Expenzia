import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense; // null = add mode, non-null = edit mode
  const AddEditExpenseScreen({super.key, this.expense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _descCtrl;

  late String _type;
  String? _category;
  late DateTime _date;
  bool _saving = false;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _amountCtrl = TextEditingController(
      text: e == null ? '' : e.amount.toStringAsFixed(2),
    );
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _type = e?.type ?? 'expense';
    _category = kCategories.contains(e?.category) ? e?.category : null;
    _date = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final desc = _descCtrl.text.trim();
    final expense = Expense(
      id: widget.expense?.id,
      title: _titleCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.trim()),
      category: _category!,
      type: _type,
      date: _date,
      description: desc.isEmpty ? null : desc,
    );

    final provider = context.read<ExpenseProvider>();
    final ok = _isEdit
        ? await provider.updateExpense(expense)
        : await provider.addExpense(expense);

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Transaction updated' : 'Transaction added'),
          duration: const Duration(seconds: 1),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Something went wrong'),
          backgroundColor: AppColors.expense,
        ),
      );
    }
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        letterSpacing: 0.5,
        color: AppColors.textGrey,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEdit ? 'Edit Transaction' : 'Transaction')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('TRANSACTION TYPE'),
                        DropdownButtonFormField<String>(
                          value: _type,
                          items: const [
                            DropdownMenuItem(
                              value: 'expense',
                              child: Text('Expense'),
                            ),
                            DropdownMenuItem(
                              value: 'income',
                              child: Text('Income'),
                            ),
                          ],
                          onChanged: (v) => setState(() => _type = v!),
                        ),

                        _label('NAME'),
                        TextFormField(
                          controller: _titleCtrl,
                          textCapitalization: TextCapitalization.sentences,
                          maxLength: 50,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Netflix',
                            counterText: '',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter a title'
                              : null,
                        ),

                        _label('AMOUNT'),
                        TextFormField(
                          controller: _amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          decoration: InputDecoration(
                            hintText: '0.00',
                            prefixText: '$kCurrency ',
                            suffixIcon: TextButton(
                              onPressed: () => _amountCtrl.clear(),
                              child: const Text(
                                'Clear',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                          validator: (v) {
                            final n = double.tryParse((v ?? '').trim());
                            if (n == null) return 'Enter a valid amount';
                            if (n <= 0) return 'Amount must be greater than 0';
                            return null;
                          },
                        ),

                        _label('CATEGORY'),
                        DropdownButtonFormField<String>(
                          value: _category,
                          hint: const Text('Select category'),
                          items: kCategories
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _category = v),
                          validator: (v) =>
                              v == null ? 'Please select a category' : null,
                        ),

                        _label('DATE'),
                        InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              suffixIcon: Icon(
                                Icons.calendar_month_outlined,
                                size: 18,
                              ),
                            ),
                            child: Text(
                              DateFormat('EEE, dd MMM yyyy').format(_date),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),

                        _label('DESCRIPTION (OPTIONAL)'),
                        TextFormField(
                          controller: _descCtrl,
                          maxLines: 3,
                          maxLength: 200,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            hintText: 'Add a note',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Save button pinned to the bottom, like the Figma
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
