part of '../main.dart';

class _LoadingBar extends StatelessWidget {
  final double progress;
  const _LoadingBar({required this.progress});
  @override
  Widget build(BuildContext context) => SizedBox(width: 200, child: Column(children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text('LOADING', style: TextStyle(color: Colors.white30, fontSize: 10, letterSpacing: 3)),
      Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Colors.cyanAccent, fontSize: 10)),
    ]),
    const SizedBox(height: 5),
    ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(
      value: progress, minHeight: 3, backgroundColor: Colors.white10,
      valueColor: const AlwaysStoppedAnimation(Colors.cyanAccent),
    )),
  ]));
}

// ══════════════════════════════════════════════════════════════
// MAIN MENU SCREEN
// ══════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final String label, value; final Color color; final IconData icon;
  const _StatCard(this.label, this.value, this.color, this.icon);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Icon(icon, color: color.withOpacity(0.8), size: 20),
    const SizedBox(height: 6),
    Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    const SizedBox(height: 4),
    Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
  ]));
}

class _MenuBtn extends StatefulWidget {
  final IconData icon; final String label; final Color color;
  final double glow; final VoidCallback onTap; final String? badge;
  const _MenuBtn({required this.icon, required this.label, required this.color,
    required this.glow, required this.onTap, this.badge});
  @override State<_MenuBtn> createState() => _MenuBtnState();
}

class _MenuBtnState extends State<_MenuBtn> with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double> _scale;
  bool _hover = false;

  @override void initState() {
    super.initState();
    _press = AnimationController(vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween(begin: 1.0, end: 0.95).animate(_press);
  }
  @override void dispose() { _press.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = widget.color;
    return GestureDetector(
      onTapDown: (_) { _press.forward(); setState(() => _hover = true); },
      onTapUp:   (_) { _press.reverse(); setState(() => _hover = false); widget.onTap(); },
      onTapCancel: () { _press.reverse(); setState(() => _hover = false); },
      child: AnimatedBuilder(animation: _press, builder: (_, __) => Transform.scale(scale: _scale.value,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 56,
              decoration: BoxDecoration(
                color: _hover ? c.withOpacity(0.15) : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _hover ? c.withOpacity(0.6) : Colors.white.withOpacity(0.05), width: 1),
                boxShadow: _hover ? [BoxShadow(color: c.withOpacity(0.3 * widget.glow), blurRadius: 20)] : [],
              ),
              child: Row(children: [
                // Left accent bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: _hover ? 6 : 4,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: _hover ? c : c.withOpacity(0.5),
                    boxShadow: [BoxShadow(color: c, blurRadius: _hover ? 12 : 0)],
                  ),
                ),
                const SizedBox(width: 16),
                // Icon with glow
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: c.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: _hover ? [BoxShadow(color: c.withOpacity(0.4), blurRadius: 10)] : [],
                  ),
                  child: Icon(widget.icon, color: c, size: 20),
                ),
                const SizedBox(width: 16),
                // Text
                Expanded(child: Text(widget.label, style: TextStyle(
                    color: _hover ? Colors.white : Colors.white70,
                    fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 4))),
                // Badge
                if (widget.badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: c.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: c.withOpacity(0.3)),
                    ),
                    child: Text(widget.badge!, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ),
                  const SizedBox(width: 12),
                ],
                // Right arrow
                Icon(Icons.arrow_forward_ios_rounded, color: _hover ? c : Colors.white24, size: 16),
                const SizedBox(width: 16),
              ]),
            ),
          ),
        ),
      )),
    );
  }
}

// ── Level Select Dialog ───────────────────────────────────────

class _LevelDialog extends StatefulWidget {
  final int selected; final ValueChanged<int> onSelect;
  const _LevelDialog({required this.selected, required this.onSelect});
  @override State<_LevelDialog> createState() => _LevelDialogState();
}

class _LevelDialogState extends State<_LevelDialog> {
  late int _sel;
  @override void initState() { super.initState(); _sel = widget.selected; }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    child: Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 340, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.amberAccent.withOpacity(0.3), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.amberAccent.withOpacity(0.15), blurRadius: 40)],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                const Icon(Icons.bar_chart_rounded, color: Colors.amberAccent, size: 24),
                const SizedBox(width: 12),
                const Text('SELECT LEVEL', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 4)),
                const Spacer(),
                GestureDetector(
                  onTap: () { HapticFeedback.mediumImpact(); Navigator.pop(context); },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 18)
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              ...LevelConfig.all.map((lv) {
                final isSelected = _sel == lv.level;
                final c = lv.unlocked ? lv.color : Colors.white24;
                return GestureDetector(
                  onTap: lv.unlocked ? () { HapticFeedback.selectionClick(); setState(() => _sel = lv.level); widget.onSelect(lv.level); } : null,
                  child: AnimatedContainer(duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                        color: isSelected ? c.withOpacity(0.15) : Colors.white.withOpacity(0.03),
                        border: Border.all(color: isSelected ? c.withOpacity(0.8) : Colors.white.withOpacity(0.05), width: isSelected ? 1.5 : 1)),
                    child: Row(children: [
                      Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle,
                          color: c.withOpacity(0.15), border: Border.all(color: c.withOpacity(0.4))),
                          child: Center(child: Text('${lv.level}', style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 16)))),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(lv.name, style: TextStyle(color: lv.unlocked ? Colors.white : Colors.white30,
                            fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 2)),
                        const SizedBox(height: 4),
                        Text(lv.subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600)),
                      ])),
                      if (!lv.unlocked) const Icon(Icons.lock_rounded, color: Colors.white24, size: 18)
                      else if (isSelected) Icon(Icons.check_circle_rounded, color: c, size: 22),
                    ]),
                  ),
                );
              }),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () { HapticFeedback.mediumImpact(); Navigator.pop(context); },
                child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                        color: Colors.amberAccent.withOpacity(0.1),
                        border: Border.all(color: Colors.amberAccent.withOpacity(0.6), width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.amberAccent.withOpacity(0.2), blurRadius: 12)]),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 4, height: 16, color: Colors.amberAccent),
                      const SizedBox(width: 12),
                      const Text('CONFIRM', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w900, letterSpacing: 4, fontSize: 14)),
                      const SizedBox(width: 12),
                      Container(width: 4, height: 16, color: Colors.amberAccent),
                    ]))),
            ]),
          ),
        ),
      ),
    ),
  );
}

// ── Settings Dialog ───────────────────────────────────────────

class _SettingsDialog extends StatefulWidget {
  final GameSettings settings; final ValueChanged<GameSettings> onChange;
  const _SettingsDialog({required this.settings, required this.onChange});
  @override State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  late GameSettings _s;
  @override void initState() { super.initState(); _s = widget.settings.copyWith(); }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    child: Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 340, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.purpleAccent.withOpacity(0.3), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.15), blurRadius: 40)],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                const Icon(Icons.settings_rounded, color: Colors.purpleAccent, size: 24),
                const SizedBox(width: 12),
                const Text('SETTINGS', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 4)),
                const Spacer(),
                GestureDetector(
                  onTap: () { HapticFeedback.mediumImpact(); Navigator.pop(context); }, 
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 18)
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              _label('MASTER VOLUME'),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.volume_mute_rounded, color: Colors.white30, size: 20),
                Expanded(child: SliderTheme(data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.purpleAccent, inactiveTrackColor: Colors.white10,
                    thumbColor: Colors.purpleAccent, overlayColor: Colors.purpleAccent.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8), trackHeight: 4),
                    child: Slider(value: _s.volume, onChanged: (v) => setState(() => _s = _s.copyWith(volume: v))))),
                const Icon(Icons.volume_up_rounded, color: Colors.white30, size: 20),
              ]),
              const SizedBox(height: 16),
              Divider(color: Colors.purpleAccent.withOpacity(0.2), thickness: 1),
              const SizedBox(height: 16),
              _toggle('SOUND EFFECTS', Icons.music_note_rounded, Colors.cyanAccent, _s.soundEnabled, (v) { HapticFeedback.selectionClick(); setState(() => _s = _s.copyWith(soundEnabled: v)); }),
              const SizedBox(height: 16),
              _toggle('BACKGROUND MUSIC', Icons.queue_music_rounded, Colors.amberAccent, _s.musicEnabled, (v) { HapticFeedback.selectionClick(); setState(() => _s = _s.copyWith(musicEnabled: v)); }),
              const SizedBox(height: 16),
              _toggle('VIBRATION', Icons.vibration_rounded, Colors.greenAccent, _s.vibrationEnabled, (v) { HapticFeedback.selectionClick(); setState(() => _s = _s.copyWith(vibrationEnabled: v)); }),
              const SizedBox(height: 32),
              GestureDetector(
                  onTap: () { HapticFeedback.mediumImpact(); widget.onChange(_s); Navigator.pop(context); },
                  child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                          color: Colors.purpleAccent.withOpacity(0.1),
                          border: Border.all(color: Colors.purpleAccent.withOpacity(0.6), width: 1.5),
                          boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.2), blurRadius: 12)]),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(width: 4, height: 16, color: Colors.purpleAccent),
                        const SizedBox(width: 12),
                        const Text('SAVE SETTINGS', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.w900, letterSpacing: 4, fontSize: 14)),
                        const SizedBox(width: 12),
                        Container(width: 4, height: 16, color: Colors.purpleAccent),
                      ]))),
            ]),
          ),
        ),
      ),
    ),
  );

  Widget _label(String t) => Align(alignment: Alignment.centerLeft,
      child: Text(t, style: const TextStyle(color: Colors.purpleAccent, fontSize: 10, letterSpacing: 2.5, fontWeight: FontWeight.bold)));

  Widget _toggle(String lbl, IconData icon, Color c, bool val, ValueChanged<bool> cb) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: c.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: c, size: 18)
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(lbl, style: const TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.w800))),
          Transform.scale(scale: 0.85, child: Switch(value: val, onChanged: cb,
              activeColor: c, activeTrackColor: c.withOpacity(0.3),
              inactiveTrackColor: Colors.white10, inactiveThumbColor: Colors.white30)),
        ]),
      );
}

// ══════════════════════════════════════════════════════════════
// GAME SCREEN
// ══════════════════════════════════════════════════════════════

