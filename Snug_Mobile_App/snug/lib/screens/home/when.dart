import 'package:flutter/material.dart';
import 'package:snug/models/Date.dart';
import 'package:snug/providers/DateProvider.dart';
import 'package:provider/provider.dart';

class When extends StatefulWidget {
  @override
  _WhenState createState() => _WhenState();
}

class _WhenState extends State<When> {
  DateTime pickedDate;
  DateTime endDate;
  TimeOfDay time;
  TimeOfDay endTime;
  DateTime finalStartDateTime;
  DateTime finalEndDateTime;

  @override
  void initState() {
    super.initState();
    final dateProvider = Provider.of<DateProvider>(context, listen: false);

    currentDate = dateProvider.getRecentDate;
    currentDate.dateStart = "";
    currentDate.dateEnd = "";
    print('printing date info');
    // print(super dateInfo)
    pickedDate = DateTime.now();
    time = TimeOfDay.now();
    endTime = TimeOfDay.now();
    endDate = DateTime.now();

    time.period == DayPeriod.am
        ? period = "AM"
        : period = "PM"; //find initial time period
    time.hour > 12 ? intHour = time.hour - 12 : intHour = time.hour;
    if (time.hour == 0) {
      intHour = 12;
    }
    time.minute < 10
        ? intMinute = "0${time.minute}"
        : intMinute = "${time.minute}";

    endTime.hour > 12 ? endHour = endTime.hour - 12 : endHour = endTime.hour;
    if (endTime.hour == 0) {
      endHour = 12;
    }
    endTime.minute < 10
        ? endMinute = "0${endTime.minute}"
        : endMinute = "${endTime.minute}";
    endTime.period == DayPeriod.am ? endPeriod = "AM" : endPeriod = "PM";
  }

  String period;
  String endPeriod;
  int intHour;
  int endHour;
  String intMinute;
  String endMinute;
  Date currentDate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        Container(
            alignment: Alignment.centerLeft,
            child: Text('Start',
                style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.secondaryVariant))),
        Row(children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width * .45,
              child: ListTile(
                title: Text(
                    "Day:\t${pickedDate.month}/${pickedDate.day}/${pickedDate.year}"),
                trailing: Icon(Icons.keyboard_arrow_down,
                    color: Theme.of(context).primaryColor),
                onTap: _pickedDate,
              )),
          Container(
            padding: EdgeInsets.all(0),
            width: MediaQuery.of(context).size.width * .45,
            child: Padding(
                padding: EdgeInsets.all(0),
                child: ListTile(
                  title: Text("Time: $intHour:$intMinute $period"),
                  trailing: Icon(Icons.keyboard_arrow_down,
                      color: Theme.of(context).primaryColor),
                  onTap: _pickedTime,
                )),
          ),
        ]),
        Divider(thickness: .9, color: Theme.of(context).primaryColor),
        Container(
            alignment: Alignment.centerLeft,
            child: Text('End',
                style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.secondaryVariant))),
        Row(children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width * .45,
              child: ListTile(
                title: Text(
                    "Day:\t${endDate.month}/${endDate.day}/${endDate.year}"),
                trailing: Icon(Icons.keyboard_arrow_down,
                    color: Theme.of(context).primaryColor),
                onTap: _pickedEndDate,
              )),
          Container(
              width: MediaQuery.of(context).size.width * .45,
              child: ListTile(
                title: Text("Time: $endHour:$endMinute $endPeriod"),
                trailing: Icon(Icons.keyboard_arrow_down,
                    color: Theme.of(context).primaryColor),
                onTap: _pickedEndTime,
              ))
        ])
      ],
    ));
  }

  updateTime() {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);

    finalStartDateTime = DateTime(pickedDate.year, pickedDate.month,
            pickedDate.day, time.hour, time.minute)
        .toUtc();
    finalEndDateTime = DateTime(endDate.year, endDate.month, endDate.day,
            endTime.hour, endTime.minute)
        .toUtc();

    String endTimeToSend = finalEndDateTime.toString();
    // endTimeToSend = endTimeToSend.substring(
    //     0,
    //     endTimeToSend.length -
    //         1); //removing 'Z' at the end. Need to put that back before converting back to local
    String startTimeToSend = finalStartDateTime.toString();
    // startTimeToSend = startTimeToSend.substring(
    //     0,
    //     startTimeToSend.length -
    //         1); //removing 'Z' at the end. Need to put that back before converting back to local

    currentDate.dateStart = startTimeToSend;
    currentDate.dateEnd = endTimeToSend;
    dateProvider.setRecentDate(currentDate);

    // THIS WILL DISPLAY LOCALLY IN THE USER'S LOCAL TIME
    //
    //         var strToDateTime = DateTime.parse(dateUtc.toString());
    // final convertLocal = strToDateTime.toLocal();
  }

  _pickedDate() async {
    DateTime date = await showDatePicker(
        context: context,
        firstDate: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day),
        lastDate: DateTime(DateTime.now().year + 5),
        initialDate: pickedDate);

    if (date != null) {
      setState(() {
        pickedDate = date; //date holds the value of the chosen date by the user
        print(pickedDate);
      });
      updateTime();
    }
  }

  _pickedEndDate() async {
    DateTime date = await showDatePicker(
        context: context,
        firstDate:
            pickedDate != null ? pickedDate : DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5),
        initialDate: pickedDate != null ? pickedDate : endDate);

    if (date != null) {
      setState(() {
        endDate = date; //date holds the value of the chosen date by the user
      });
    }
    updateTime();
  }

  _pickedTime() async {
    TimeOfDay t = await showTimePicker(
      context: context,
      initialTime: time,
    );

    if (t != null) {
      setState(() {
        time = t;
        //t holds the value of the chosen time of the user
        time.hour > 12
            ? intHour = time.hour - 12
            : intHour = time.hour; // convert military time to regular
        if (time.hour == 0) {
          intHour = 12;
        }
        time.minute < 10
            ? intMinute = "0${time.minute}"
            : intMinute = "${time.minute}";

        t.period == DayPeriod.am ? period = "AM" : period = "PM";
      });
    }
    updateTime();
  }

  _pickedEndTime() async {
    TimeOfDay t = await showTimePicker(
      context: context,
      initialTime: endTime,
    );

    if (t != null) {
      setState(() {
        endTime = t;
        print(endTime);
        print('picked date: ');
        print(pickedDate);
        // pickedDate.hour = //t holds the value of the chosen time of the user
        endTime.hour > 12
            ? endHour = endTime.hour - 12
            : endHour = endTime.hour; // convert military time to regular
        if (endTime.hour == 0) {
          endHour = 12;
        }
        endTime.minute < 10
            ? endMinute = "0${endTime.minute}"
            : endMinute = "${endTime.minute}";

        t.period == DayPeriod.am ? endPeriod = "AM" : endPeriod = "PM";
      });
    }
    updateTime();
  }
}
