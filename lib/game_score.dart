
// game_score.dart
class GameScore {
  int numCorrectSpottos = 0;
  int numCorrectFroggos = 0;
  int numWrongSpottos = 0;
  int numWrongFroggos = 0;
  
  // Calculate the total score
  int get totalScore => 
      (numCorrectSpottos + numCorrectFroggos) - 
      (numWrongSpottos + numWrongFroggos);
}
