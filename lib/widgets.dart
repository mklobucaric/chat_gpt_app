// Importing required material design library.
import 'package:flutter/material.dart';

// Defining a stateful widget "SliderWidget".
class SliderWidget extends StatefulWidget {
  // Initial parameters declarations with the datatype and function type.
  final double value; // Final immutable double type variable 'value'.
  final ValueChanged<double>
      onChanged; // ValueChanged function type variable which takes double type as input.
  final VoidCallback
      onSendPressed; // VoidCallback type function to handle the 'onSendPressed' event.

  // SliderWidget constructor
  SliderWidget({
    required this.value,
    required this.onChanged,
    required this.onSendPressed,
  });

  // Pointing to the state of this StatefulWidget.
  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

// Defining the state of the above StatefulWidget "SliderWidget".
class _SliderWidgetState extends State<SliderWidget> {
  late double _sliderValue; // Declare a double type late initialized variable.

  // Initializing the state.
  @override
  void initState() {
    super.initState();
    _sliderValue = widget
        .value; // Assigned the value to _sliderValue variable from the widget state.
  }

  // Building the Widget.
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        // Defining the properties of Slider.
        Slider(
          value: _sliderValue, // The current value of the Slider.
          label: _sliderValue.toStringAsFixed(
              1), // The label shown next to the Slider when it is selected.
          divisions: 21, // Number of discrete divisions.
          thumbColor: Colors.blue, // Color of the slider thumb.
          activeColor: Colors
              .redAccent, // Color of the portion of the Slider that has been selected.
          min: 0, // Minimum position of the slider.
          max: 2, // Maximum position of the slider.
          onChanged: (double value) {
            // Updating the value whenever the slider been moved.
            setState(() {
              _sliderValue = value;
            });
            widget.onChanged(value);
          },
        ),
        // Defining the IconButton and its properties.
        IconButton(
          icon: const Icon(Icons.send), // Icon to show on the button.
          onPressed: widget
              .onSendPressed, // Event to be triggered when the button pressed.
        ),
      ],
    );
  }
}
