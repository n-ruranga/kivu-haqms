import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_state.dart';

class OtpVerificationPage extends StatefulWidget{
  const OtpVerificationPage({required this.verificationId, super.key});

  final String verificationId;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>{
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose(){
    _codeController.dispose();
    super.dispose();
  }

  void _submit(){
    if(!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().verifyOtp(
      verificationId: widget.verificationId,
      smsCode: _codeController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state){
            if(state is AuthFailure){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Enter verification code',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Enter the 6-digit code you received on your phone',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    decoration: const InputDecoration(
                      counterText: '',
                      hintText: '------',
                    ),
                    validator: (value){
                      if(value == null || value.trim().length != 6){
                        return 'Enter the 6-digit code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state){
                      final isLoading = state is AuthLoading;
                      return FilledButton(
                        onPressed: isLoading ? null : _submit,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Verify & Continue'),
                          );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
