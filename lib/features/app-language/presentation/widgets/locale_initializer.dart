import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hawiah_driver/features/app-language/presentation/controllers/app-language-cubit/app-language-cubit.dart';

/// A widget that initializes the app locale from saved preferences.
/// Should be placed high in the widget tree, after EasyLocalization but before any localized widgets.
class LocaleInitializer extends StatefulWidget {
  final Widget child;

  const LocaleInitializer({
    super.key,
    required this.child,
  });

  @override
  State<LocaleInitializer> createState() => _LocaleInitializerState();
}

class _LocaleInitializerState extends State<LocaleInitializer> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocale();
    });
  }

  Future<void> _initializeLocale() async {
    if (!_initialized && mounted) {
      _initialized = true;
      final cubit = context.read<AppLanguageCubit>();
      await cubit.initializeLocale(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}