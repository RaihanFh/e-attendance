import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hc/data/localdb.dart';
import 'package:hc/data/global_variable.dart';
import 'package:slide_to_act/slide_to_act.dart';

class ClockSlider extends StatefulWidget {
  final LocalDb localDb;
  final int index;
  final bool isLoading;
  final String sliderType;
  final bool enableSlider;
  final Function(BuildContext context, String type) handler;

  const ClockSlider({
    required this.localDb,
    required this.index,
    required this.sliderType,
    required this.isLoading,
    required this.handler,
    required this.enableSlider,
    super.key
  });

  @override
  State<ClockSlider> createState() => _ClockSliderState();
}

class _ClockSliderState extends State<ClockSlider> {
  @override
  Widget build(BuildContext context) {    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: SlideAction(
        submittedIcon: Icon(Icons.punch_clock_rounded,color: Colors.white,),
        borderRadius: 12,
        elevation: 0,
        innerColor: widget.enableSlider? Colors.white : Colors.transparent,
        outerColor: (widget.sliderType == 'Clock In')
          ? Color(0xFF4CAF50)
          : (widget.sliderType == 'Clock Out')
            ? Color(0xFF2196F3)
            : greenTheme
        ,
        enabled: widget.enableSlider && !widget.isLoading,
        sliderRotate: false,
        text: !widget.isLoading ? widget.sliderType :'Loading...',
        textStyle: GoogleFonts.lato(
          color: Colors.white,
          fontSize: 24
        ),
        sliderButtonIcon: !widget.isLoading 
          ? (widget.sliderType == 'Clock In')
            ? Icon(Icons.login_outlined, color: Color(0xFF4CAF50),)
            : Icon(Icons.logout_outlined, color: (widget.sliderType == 'Clock Out')? Color(0xFF2196F3) : Colors.transparent)
          : CircularProgressIndicator(color: greenTheme),
        onSubmit: () async {
          DateTime now = DateTime.now();
          DateTime date = (widget.sliderType == 'Clock In')
            ? widget.localDb.toDate(widget.localDb.scheduleList[widget.index].scheduleIn)
            : widget.localDb.toDate(widget.localDb.scheduleList[widget.index].scheduleOut);
          bool rules = (widget.sliderType == 'Clock In')
            ? ((now.year == date.year && now.month == date.month && now.day == date.day) && now.isAfter(date.subtract(const Duration(minutes: 10))))
            : (now.year == date.year && now.month == date.month && now.day == date.day) && now.isAfter(date);
          if (rules){
            widget.handler(context, widget.sliderType);
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: widgetBg,
                title: const Text('Reminder'),
                content: (widget.sliderType == 'Clock In')
                ? const Text('You can only Clock In 10 minutes behind schedule')
                : const Text('You can only Clock Out after schedule') ,
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: Text('Ok', style: TextStyle(color: greenTheme)),
                  ),
                ],
              ),
            );
          }
        },
      )
    );
  }
}

