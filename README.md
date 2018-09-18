# Highlighter Coach Mark

There are different ways for user on-boarding. It can be a show of screenshots or overlay with directions to features,
feature discovery as in Material design or coach mark. This coach mark makes blurred background and highlights desired element.

This coach mark makes blurred background and highlights desired element.

A picture is worth a thousand words, so take a look at gif

And a few tips from UX 
>Presenting hints one-by-one, at the right moment, makes it a lot easier for users to understand and learn instructions. 

>To have their full effect, coach marks should focus on particularly innovative or unexpected elements. 

## Usage
Take a look at example folder. There are also 4 coach marks there. They are all presented in gif above
```dart
  CoachMark coachMark = CoachMark();
  RenderBox target = targetGlobalKey.currentContext.findRenderObject();
  Rect markRect = target.localToGlobal(Offset.zero) & target.size;
  markRect = Rect.fromCircle(center: markRect.center, radius: markRect.longestSide * 0.6);
  coachMark.show(
      targetContext: targetGlobalKey.currentContext,
      markRect: markRect,
      children: [
        Positioned(
            top: markRect.top + 5.0,
            right: 10.0,
            child: Text("Long tap on button to see options",
                style: const TextStyle(
                  fontSize: 24.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                )))
      ],
      duration: null,
      onClose: () {
         appState.setCoachMarkIsShown(true);
      });
```

Credits to [Iiro Krankka](https://iirokrankka.com/) by using his [FlutterMates](https://github.com/CodemateLtd/FlutterMates)