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
                      return const Center(child: Icon(Icons.error));
                    },
                  ),
                ),
              ),
              Positioned(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black.withOpacity(0.25),
                  ),
                  child: Center(
                    child: Text(
                      '${character?.name ?? ''}${character?.status == CharacterStatus.dead ? '\n(Dead)' : ''}',
                      style: const TextStyle(
                        color: Colors.yellowAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
