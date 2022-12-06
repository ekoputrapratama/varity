// this should be a constant for android device's max brightness, I can't find
// a way to retrieve this max brightness either in kotlin or java and  i think every
// manufacturer have a different max brightness, i remember that in my old
// Vivo device have a max brightness of 255 but on my current device Xiaomi
// it have a max brightness up to 2047 so I'll put this here for now, in
// hope that the android team can add this feature
final Map<String, double> maxBrightnessMap = {
  "Xiaomi M2101K6G": 2047.0,
  "default": 255.0
};
