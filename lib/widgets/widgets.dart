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
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.withOpacity(0.5), width: 1), // The outer thin border
            boxShadow: [
              // Ambient glow around the whole button
              BoxShadow(color: c.withOpacity(_hover ? 0.3 : 0.08), blurRadius: 12, spreadRadius: 0),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13), // Clip children to fit inside border
            child: Stack(
              alignment: Alignment.center,
              children: [
              // 1. Solid dark base
              Container(color: const Color(0xFF070910)),
              
              // 2. Beautiful background gradient fading from left to right
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [c.withOpacity(_hover ? 0.4 : 0.25), c.withOpacity(0.05), Colors.transparent],
                    stops: const [0.0, 0.4, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              
              // 3. The glowing thick left edge (Neon tube effect)
              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: c, // Solid neon color
                    boxShadow: [
                      BoxShadow(color: c, blurRadius: 12, spreadRadius: 4), // Outer intense glow
                      BoxShadow(color: Colors.white.withOpacity(0.6), blurRadius: 4), // Inner bright core
                    ],
                  ),
                ),
              ),
              
              // 4. Content
              Row(children: [
                const SizedBox(width: 14),
                // Icon in circle
                Container(
                  width: 40, height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.withOpacity(0.1), // Tinted background
                    border: Border.all(color: c.withOpacity(0.5), width: 1.5),
                  ),
                  child: Icon(widget.icon, color: c, size: 20),
                ),
                const SizedBox(width: 16),
                // Text
                Expanded(child: Text(widget.label, 
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 3.5))),
                // Badge
                if (widget.badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: c, width: 1.2),
                      boxShadow: [BoxShadow(color: c.withOpacity(0.2), blurRadius: 4)],
                    ),
                    child: Text(widget.badge!, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ),
                  const SizedBox(width: 12),
                ],
                // Right arrow
                Icon(Icons.arrow_forward_ios_rounded, color: c, size: 18),
                const SizedBox(width: 14),
              ]),
            ]),
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
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 340, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0C14).withOpacity(0.95), // Clean dark background
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.amber.withOpacity(0.4), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.1), blurRadius: 24)],
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
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected ? null : const Color(0xFF131620), // Subtle card bg for unselected
                        gradient: isSelected ? LinearGradient(colors: [c.withOpacity(0.15), Colors.transparent], begin: Alignment.centerLeft, end: Alignment.centerRight) : null,
                        border: Border.all(color: isSelected ? c.withOpacity(0.8) : c.withOpacity(0.2), width: isSelected ? 1.5 : 1),
                        boxShadow: isSelected ? [BoxShadow(color: c.withOpacity(0.2), blurRadius: 16)] : []),
                    child: Row(children: [
                      Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle,
                          color: isSelected ? c.withOpacity(0.15) : Colors.transparent, 
                          border: Border.all(color: isSelected ? c.withOpacity(0.8) : c.withOpacity(0.3), width: isSelected ? 1.5 : 1)),
                          child: Center(child: Text('${lv.level}', style: TextStyle(color: isSelected ? Colors.white : c, fontWeight: FontWeight.w900, fontSize: 16)))),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(lv.name, style: const TextStyle(color: Colors.white,
                            fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 2)),
                        const SizedBox(height: 4),
                        Text(lv.subtitle, style: TextStyle(color: c.withOpacity(isSelected ? 1.0 : 0.6), fontSize: 10, fontWeight: FontWeight.w600)),
                      ])),
                      if (!lv.unlocked) const Icon(Icons.lock_rounded, color: Colors.white24, size: 18)
                      else if (isSelected) Icon(Icons.check_circle_outline_rounded, color: c, size: 22),
                    ]),
                  ),
                );
              }),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () { HapticFeedback.mediumImpact(); Navigator.pop(context); },
                child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(colors: [Colors.amber.withOpacity(0.15), Colors.amber.withOpacity(0.02)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                        border: Border.all(color: Colors.amber.withOpacity(0.8), width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.2), blurRadius: 16)]),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 4, height: 16, color: Colors.amber),
                      const SizedBox(width: 12),
                      const Text('CONFIRM', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, letterSpacing: 4, fontSize: 14)),
                      const SizedBox(width: 12),
                      Container(width: 4, height: 16, color: Colors.amber),
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
              color: const Color(0xFF0A0C14).withOpacity(0.95), // Clean dark background
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.purpleAccent.withOpacity(0.4), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.15), blurRadius: 24)],
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
                const Icon(Icons.volume_down_rounded, color: Colors.purpleAccent, size: 20),
                Expanded(child: SliderTheme(data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.purpleAccent, inactiveTrackColor: Colors.white10,
                    thumbColor: Colors.purpleAccent, overlayColor: Colors.purpleAccent.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8), trackHeight: 4),
                    child: Slider(value: _s.volume, onChanged: (v) => setState(() => _s = _s.copyWith(volume: v))))),
                const Icon(Icons.volume_up_rounded, color: Colors.purpleAccent, size: 20),
              ]),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: Container(height: 1, color: Colors.purpleAccent.withOpacity(0.2))),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.star, color: Colors.purpleAccent, size: 12)),
                Expanded(child: Container(height: 1, color: Colors.purpleAccent.withOpacity(0.2))),
              ]),
              const SizedBox(height: 20),
              _toggle('SOUND EFFECTS', Icons.music_note_rounded, Colors.cyanAccent, _s.soundEnabled, (v) { HapticFeedback.selectionClick(); setState(() => _s = _s.copyWith(soundEnabled: v)); }),
              _toggle('BACKGROUND MUSIC', Icons.queue_music_rounded, Colors.amberAccent, _s.musicEnabled, (v) { HapticFeedback.selectionClick(); setState(() => _s = _s.copyWith(musicEnabled: v)); }),
              _toggle('VIBRATION', Icons.vibration_rounded, Colors.greenAccent, _s.vibrationEnabled, (v) { HapticFeedback.selectionClick(); setState(() => _s = _s.copyWith(vibrationEnabled: v)); }),
              const SizedBox(height: 32),
              GestureDetector(
                  onTap: () { HapticFeedback.mediumImpact(); widget.onChange(_s); Navigator.pop(context); },
                  child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(colors: [Colors.purpleAccent.withOpacity(0.2), Colors.purpleAccent.withOpacity(0.02)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                          border: Border.all(color: Colors.purpleAccent.withOpacity(0.8), width: 1.5),
                          boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.25), blurRadius: 16)]),
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
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF131620), // Dark card background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withOpacity(0.3), width: 1.5),
          boxShadow: [BoxShadow(color: c.withOpacity(0.05), blurRadius: 12)],
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: c.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: c.withOpacity(0.4), width: 1.5)),
            child: Icon(icon, color: c, size: 18)
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(lbl, style: const TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 1.5, fontWeight: FontWeight.w800))),
          Transform.scale(scale: 0.9, child: Switch(value: val, onChanged: cb,
              activeColor: c, activeTrackColor: c.withOpacity(0.3),
              inactiveTrackColor: Colors.white10, inactiveThumbColor: Colors.white30)),
        ]),
      );
}

// ══════════════════════════════════════════════════════════════
// GAME SCREEN
// ══════════════════════════════════════════════════════════════

