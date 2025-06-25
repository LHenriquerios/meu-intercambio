import 'package:flutter/material.dart';
import 'package:meu_intercambio_prototype/models/offer_model.dart';
import 'package:meu_intercambio_prototype/services/offer_service.dart';
import 'package:meu_intercambio_prototype/services/auth_service.dart';
import 'package:intl/intl.dart';

class NewOfferScreen extends StatefulWidget {
  final Offer? offerToEdit;

  const NewOfferScreen({super.key, this.offerToEdit});

  @override
  State<NewOfferScreen> createState() => _NewOfferScreenState();
}

class _NewOfferScreenState extends State<NewOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _entryTimeController = TextEditingController();
  final _exitTimeController = TextEditingController();
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();
  final OfferService _offerService = OfferService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    if (widget.offerToEdit != null) {
      _dateController.text = widget.offerToEdit!.date;
      _entryTimeController.text = widget.offerToEdit!.entryTime;
      _exitTimeController.text = widget.offerToEdit!.exitTime;
      _valueController.text = widget.offerToEdit!.value.toString();
      _notesController.text = widget.offerToEdit!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _entryTimeController.dispose();
    _exitTimeController.dispose();
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }

  Future<void> _submitOffer() async {
    if (!_formKey.currentState!.validate()) return;

    // Busca os dados do usuário do Firestore
    final userData = await _authService.getCurrentUserData();
    // Pega o ID do usuário do Auth
    final userId = _authService.currentUser?.uid;

    if (userData == null || userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: Usuário não encontrado. Faça login novamente.')),
        );
      }
      return;
    }

    final offer = Offer(
      id: widget.offerToEdit?.id ?? '', // Mantém o ID se estiver editando
      date: _dateController.text,
      entryTime: _entryTimeController.text,
      exitTime: _exitTimeController.text,
      value: double.parse(_valueController.text),
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      username: userData['nomeDeGuerra'] ?? 'N/A', // Usa os dados do Firestore
      institution: userData['instituicao'] ?? 'N/A', // Usa os dados do Firestore
      userId: userId, // Usa o ID do Auth
    );

    try {
      if (widget.offerToEdit != null) {
        await _offerService.updateOffer(offer.id, offer);
      } else {
        await _offerService.createOffer(offer);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.offerToEdit != null
                ? 'Oferta atualizada com sucesso!'
                : 'Oferta publicada com sucesso!'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar oferta: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.offerToEdit != null ? 'Editar Oferta' : 'Publicar Oferta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Data',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _selectDate,
                    ),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a data';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _entryTimeController,
                        decoration: InputDecoration(
                          labelText: 'Entrada',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _selectTime(_entryTimeController),
                          ),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o horário';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _exitTimeController,
                        decoration: InputDecoration(
                          labelText: 'Saída',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _selectTime(_exitTimeController),
                          ),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o horário';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valueController,
                  decoration: const InputDecoration(
                    labelText: 'Valor oferecido (R\$)',
                    border: OutlineInputBorder(),
                    prefixText: 'R\$ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o valor';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Por favor, insira um valor válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitOffer,
                    child: Text(widget.offerToEdit != null ? 'Atualizar Oferta' : 'Publicar Oferta'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}