import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDropdownWidget extends StatelessWidget {
  final String labelText;
  final String? selectedValue;
  final List<String> items;
  final Function(String?) onChanged;
  final String? iconAsset;

  const CustomDropdownWidget({
    Key? key,
    required this.labelText,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    this.iconAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 15.h,
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: labelText,
          prefixIconConstraints: BoxConstraints(maxWidth: 50, maxHeight: 30),
          prefixIcon: iconAsset != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Image.asset(
                    iconAsset!,
                    fit: BoxFit.fill,
                  ),
                )
              : null,
        ),
        initialValue: selectedValue,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        icon: Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xffEDEEFF),
          ),
          child: Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }
}
