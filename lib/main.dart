import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Define the Flashcard model
class Flashcard {
  final String question;
  final String answer;

  Flashcard({required this.question, required this.answer});

  // Convert Flashcard to JSON format
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
    };
  }

  // Create a Flashcard from JSON format
  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      question: json['question'],
      answer: json['answer'],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flashcard App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.purple[100],
      ),
      home: FlashcardScreen(),
    );
  }
}

class FlashcardScreen extends StatefulWidget {
  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Flashcard> _flashcards = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    final String? flashcardsJson = prefs.getString('flashcards');
    if (flashcardsJson != null) {
      final List<dynamic> decodedJson = json.decode(flashcardsJson);
      setState(() {
        _flashcards = decodedJson.map((jsonItem) => Flashcard.fromJson(jsonItem)).toList();
      });
    }
  }

  Future<void> _saveFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> flashcardsJson = _flashcards.map((card) => card.toJson()).toList();
    await prefs.setString('flashcards', json.encode(flashcardsJson));
  }

  void _addFlashcard() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController questionController = TextEditingController();
        final TextEditingController answerController = TextEditingController();

        return AlertDialog(
          title: Text('Add Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: InputDecoration(labelText: 'Question'),
              ),
              TextField(
                controller: answerController,
                decoration: InputDecoration(labelText: 'Answer'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final String question = questionController.text;
                final String answer = answerController.text;

                if (question.isNotEmpty && answer.isNotEmpty) {
                  setState(() {
                    _flashcards.add(Flashcard(question: question, answer: answer));
                    _saveFlashcards();
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showNextCard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _flashcards.length;
    });
  }

  void _showPreviousCard() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _flashcards.length) % _flashcards.length;
    });
  }

  void _deleteFlashcard() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Flashcard'),
          content: Text('Are you sure you want to delete this flashcard?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _flashcards.removeAt(_currentIndex);
                  if (_flashcards.isNotEmpty) {
                    _currentIndex = _currentIndex % _flashcards.length;
                  } else {
                    _currentIndex = 0;
                  }
                  _saveFlashcards();
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('French vocabulary'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addFlashcard,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _flashcards.isNotEmpty ? _deleteFlashcard : null,
          ),
        ],
      ),
      body: _flashcards.isEmpty
          ? Center(child: Text('No flashcards available. Add some!'))
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            // Adjust the width and height as needed
            width: 250,
            height: 200,
            child: FlipCard(
              front: _buildCardView(
                _flashcards[_currentIndex].question,
                Colors.purple[200]!,
              ),
              back: _buildCardView(
                _flashcards[_currentIndex].answer,
                Colors.purple[300]!,
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton.icon(
                onPressed: _showPreviousCard,
                icon: Icon(Icons.chevron_left),
                label: Text('Prev'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple[800], // Dark purple text color
                  backgroundColor: Colors.purple[200], // Light purple background
                  side: BorderSide(color: Colors.purple[300]!, width: 2), // Dark purple border
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _showNextCard,
                icon: Icon(Icons.chevron_right),
                label: Text('Next'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple[800], // Dark purple text color
                  backgroundColor: Colors.purple[200], // Light purple background
                  side: BorderSide(color: Colors.purple[300]!, width: 2), // Dark purple border
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
          SizedBox(height: 20), // Space between buttons and bottom of screen
        ],
      ),
    );
  }

  Widget _buildCardView(String text, Color color) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple[300]!, // Dark purple border color
          width: 2, // Border width
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      width: 300,
      height: 200,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 35, color: Colors.white),
      ),
    );
  }
}
