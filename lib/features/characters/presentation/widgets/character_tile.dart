import 'package:flutter/material.dart';
import 'package:jarboss_challenge/features/characters/domain/entities/character_entity.dart';

class CharacterTile extends StatelessWidget {
  final Function(CharacterEntity?) onSelectCharacter;
  final CharacterEntity? character;

  const CharacterTile({
    super.key,
    required this.onSelectCharacter,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: InkWell(
        onTap: () => onSelectCharacter(character),
        child: Card(
          surfaceTintColor: Colors.transparent,
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          elevation: 4,
          shadowColor: Colors.deepPurple,
          child: Stack(
            children: [
              
              Hero(
                tag: character?.id ?? '',
                transitionOnUserGestures: true,

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    height: double.infinity,
                    width: double.infinity,
                    character?.imageUrl ?? '',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.broken_image));
                    },
                  ),
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      (character?.status == CharacterStatus.dead
                              ? Colors.red
                              : character?.status == CharacterStatus.alive
                              ? Colors.green
                              : Colors.white)
                          .withValues(alpha: 0.8),
                      (character?.status == CharacterStatus.dead
                              ? Colors.red
                              : character?.status == CharacterStatus.alive
                              ? Colors.green
                              : Colors.white)
                          .withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    tileMode: TileMode.clamp,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                    child: Text(
                    character?.name ?? '',
                      style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
