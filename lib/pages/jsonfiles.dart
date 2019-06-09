class Messages
{
  final status;
  final moisture;
  final upThreshold;
  final downThreshold;
  final language;
  final pulse;
  final wtstatus,water,tankHeight, soilTemp;
  Messages({this.status,this.soilTemp,this.tankHeight,this.moisture,this.upThreshold, this.downThreshold,this.language,this.pulse, this.water, this.wtstatus});
  
  Messages.fromJson(Map<String, dynamic> jsn): 
        status = jsn['status'],
        moisture=jsn['moisture'],
        upThreshold=jsn['upThreshold'],
        downThreshold=jsn['downThreshold'],
        language=jsn['language'],
        water=jsn['water'],
        wtstatus=jsn['wtstatus'],
        tankHeight=jsn['tankHeight'],
        soilTemp=jsn['soilTemp'],
        pulse=jsn['pulse'];
  Map<String, dynamic> toJson() =>
    {
      'status': status,
      'moisture': moisture,
      'upThreshold':upThreshold,
      'downThreshold':downThreshold,
      'language':language,
      'water':water,
      'wtstatus': wtstatus,
      'soilTemp': soilTemp,
      'tankHeight':tankHeight,
      'pulse': pulse
    };
}

class Store
{
  final status;
  final moisture;
  final timestamp;
  Store({this.status,this.moisture,this.timestamp});
  
  Store.fromJson(Map<String, dynamic> jsn): 
        status = jsn['status'],
        moisture=jsn['moisture'],
        timestamp=jsn['timestamp'];
  
  Map<String, dynamic> toJson() =>
    {
      'status': status,
      'moisture': moisture,
      'timestamp':timestamp,
    };
}