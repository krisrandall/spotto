// game_score.dart
import 'package:shared_preferences/shared_preferences.dart';

class GameScore {
  int numCorrectSpottos = 0;
  int numCorrectFroggos = 0;
  int numWrongSpottos = 0;
  int numWrongFroggos = 0;
  
  bool isUnlimitedMode = false;
  int gameDurationInSeconds = 0;
  
  // Calculate the total score
  int get totalScore => 
      (numCorrectSpottos + numCorrectFroggos) - 
      (numWrongSpottos + numWrongFroggos);
  
  // Reset the score
  void reset() {
    numCorrectSpottos = 0;
    numCorrectFroggos = 0;
    numWrongSpottos = 0;
    numWrongFroggos = 0;
  }
  
  // Save the score to local storage
  Future<void> saveScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get current high score
      final currentHighScore = prefs.getInt('highScore') ?? 0;
      
      // Save last score
      prefs.setInt('lastScore', totalScore);
      prefs.setInt('lastScoreDuration', gameDurationInSeconds);
      prefs.setBool('lastScoreIsUnlimited', isUnlimitedMode);
      
      // Check if this is a new high score
      if (totalScore > currentHighScore) {
        // Save new high score
        prefs.setInt('highScore', totalScore);
        prefs.setInt('highScoreDuration', gameDurationInSeconds);
        prefs.setBool('highScoreIsUnlimited', isUnlimitedMode);
      }
    } catch (e) {
      print('Error saving score: $e');
    }
  }
}