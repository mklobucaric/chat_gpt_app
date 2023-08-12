import 'package:flutter/material.dart';

class SliderWidget extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final VoidCallback onSendPressed;

  SliderWidget({
    required this.value,
    required this.onChanged,
    required this.onSendPressed,
  });

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Slider(
          value: _sliderValue,
          label: _sliderValue.toStringAsFixed(1),
          divisions: 21,
          thumbColor: Colors.blue,
          activeColor: Colors.redAccent,
          min: 0,
          max: 2,
          onChanged: (double value) {
            setState(() {
              _sliderValue = value;
            });
            widget.onChanged(value);
          },
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: widget.onSendPressed,
        ),
      ],
    );
  }
}
