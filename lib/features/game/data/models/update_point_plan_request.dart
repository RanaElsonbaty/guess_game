class UpdatePointPlanRequest {
  final int gameId;
  final List<RoundDataUpdate> roundsData;

  UpdatePointPlanRequest({
    required this.gameId,
    required this.roundsData,
  });

  Map<String, dynamic> toJson() {
    return {
      'game_id': gameId,
      'rounds_data': roundsData.map((round) => round.toJson()).toList(),
    };
  }
}

class RoundDataUpdate {
  final int roundDataId;
  final int pointPlan;

  RoundDataUpdate({
    required this.roundDataId,
    required this.pointPlan,
  });

  Map<String, dynamic> toJson() {
    return {
      'round_data_id': roundDataId,
      'point_plan': pointPlan,
    };
  }
}



