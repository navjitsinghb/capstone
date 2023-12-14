import 'package:flutter/material.dart';


extension ThemeValue<T> on BuildContext {
  T themeValue({required T light, T? dark}) {
    return Theme.of(this).brightness == Brightness.light ? light : dark ?? light;
  }
}
class AppFont {
  static const String montserrat = 'Montserrat';
  static const String nunito = 'Nunito';
}
class AppColor {
  static const Color white = Color(0xFFC4C4C4);
  static const Color black = Color(0xFF000000);
}
class AppText {
  static const String fitness = "Fitness";
  static const String hi = "Hi!";
  static const String steps = "Steps";
  static const String caloriesBurned = "Calories Burned";
  static const String goal = "Goal";
  static const String retry = "RETRY";
  static const String exit = "EXIT";
  static const String error = "Please authenticate to procide";
}
class HomeCard extends StatelessWidget {
  const HomeCard(
      {required this.title,
      required this.goal,
      required this.iconPath,
      required this.heading,
      required this.value,
      Key? key})
      : super(key: key);
  final String iconPath;
  final String title;
  final String goal;
  final String heading;
  final double value;
  final TextStyle _titleStyle = const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    fontFamily: AppFont.nunito,
  );
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 122,
      width: MediaQuery.of(context).size.width,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          //border color black
          side: const BorderSide(color: AppColor.black),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(17, 16, 8, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$heading: ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontFamily: AppFont.montserrat,
                            ),
                          ),
                          // TextSpan(
                          //   text: title,
                          //   style: const TextStyle(
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.w600,
                          //     fontFamily: AppFont.nunito,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          /// change the value of the progress bar
                          value: value / 100, // value is taking the value of the steps and dividing it by 100 to show the progress bar
                          valueColor: AlwaysStoppedAnimation(
                            context.themeValue(light: Color.fromARGB(255, 0, 0, 0), dark: Color.fromARGB(255, 255, 255, 255)),
                          ),
                          backgroundColor: Color.fromARGB(255, 122, 118, 118),
                          minHeight: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${"Progress"}: $value',
                          style: _titleStyle,
                        ),
                        Text(
                          '${AppText.goal}: $goal',
                          style: _titleStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 21),
              SizedBox(
                height: 52,
                width: 52,
                child: Image.asset(iconPath),
              )
            ],
          ),
        ),
      ),
    );
  }
}