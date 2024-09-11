import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ina_17_test/calculator_bloc.dart';

void main() {
  FlavorConfig(
    flavor: Flavor.red,
    name: 'Red Calculator',
    themeColor: Colors.red,
    useCamera: false,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => CalculatorBloc(),
        child: MaterialApp(
          title: FlavorConfig.instance.name,
          theme: ThemeData(
            primaryColor: FlavorConfig.instance.themeColor,
          ),
          home: const CalculatorScreen(),
        ));
    /*
    return MaterialApp(
      title: FlavorConfig.instance.name,
      theme: ThemeData(
        primaryColor: FlavorConfig.instance.themeColor,
      ),
      home: const CalculatorScreen(),
    );
  */
  }
}

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlavorConfig.instance.name),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Input an Expression',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: Text(FlavorConfig.instance.useCamera
                ? 'Use Camera'
                : 'Pick Image from Gallery'),
            onPressed: () {
              if (FlavorConfig.instance.useCamera) {
                _pickImageFromCamera(context);
              } else {
                _pickImageFromGallery(context);
              }
            },
          ),
          const SizedBox(height: 20),
          Expanded(child: _buildRecentResultsList(context)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Use File Storage'),
              Switch(
                value: context.read<CalculatorBloc>().state.useFileStorage,
                onChanged: (bool value) {
                  context.read<CalculatorBloc>().add(ToggleStorage(value));
                },
              ),
              const Text('Use Database Storage'),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromCamera(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      context.read<CalculatorBloc>().add(ProcessImage(pickedFile.path));
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      context.read<CalculatorBloc>().add(ProcessImage(pickedFile.path));
    }
  }

  Widget _buildRecentResultsList(BuildContext context) {
    return BlocBuilder<CalculatorBloc, CalculatorState>(
      builder: (context, state) {
        if (state.recentResults.isEmpty) {
          return const Center(child: Text('No recent results'));
        }
        return ListView.builder(
          itemCount: state.recentResults.length,
          itemBuilder: (context, index) {
            final result = state.recentResults[index];
            return ListTile(
              title: Text(result.expression),
              subtitle: Text('Result: ${result.result}'),
            );
          },
        );
      },
    );
  }
}

abstract class CalculatorEvent {}

class ProcessImage extends CalculatorEvent {
  final String imagePath;

  ProcessImage(this.imagePath);
}

class ToggleStorage extends CalculatorEvent {
  final bool useFileStorage;

  ToggleStorage(this.useFileStorage);
}

class FlavorConfig {
  final Flavor flavor;
  final String name;
  final Color themeColor;
  final bool useCamera;

  static FlavorConfig? _instance;

  factory FlavorConfig({
    required Flavor flavor,
    required String name,
    required Color themeColor,
    required bool useCamera,
  }) {
    _instance ??= FlavorConfig._internal(
      flavor: flavor,
      name: name,
      themeColor: themeColor,
      useCamera: useCamera,
    );
    return _instance!;
  }

  FlavorConfig._internal({
    required this.flavor,
    required this.name,
    required this.themeColor,
    required this.useCamera,
  });

  static FlavorConfig get instance => _instance!;
}

enum Flavor { red, green }
