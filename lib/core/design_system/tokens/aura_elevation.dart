import 'package:flutter/painting.dart';

/// Border-width tokens for the AURA Design System.
///
/// AURA defines hierarchy with hairlines, not shadows. The border *color* is
/// theme-dependent and comes from the semantic layer (`colors.borderDefault`);
/// only the widths are fixed here.
class AuraBorders {
  const AuraBorders._();

  static const double hairline = 1;
  static const double focus = 2;
  static const double focusOffset = 2;
}

/// Elevation tokens for the AURA Design System.
///
/// Depth is expressed border-first. Shadows are intentionally private raw
/// values, reachable ONLY through these four named treatments so a border-first
/// system cannot silently drift into a shadow-first one.
///
/// `flat` and `card` carry no shadow: `card`'s separation is a hairline border,
/// composed at the component layer with [AuraBorders.hairline] and the semantic
/// border color. `overlay` and `modal` are the only treatments that float.
class AuraElevation {
  const AuraElevation._();

  static const BoxShadow _subtle = BoxShadow(
    color: Color(0x0F000000),
    offset: Offset(0, 2),
    blurRadius: 8,
  );

  static const BoxShadow _floating = BoxShadow(
    color: Color(0x1F000000),
    offset: Offset(0, -4),
    blurRadius: 24,
  );

  /// E0: backgrounds, reading canvas. No border, no shadow.
  static const List<BoxShadow> flat = <BoxShadow>[];

  /// E1: cards, tiles, inputs. Border only (no shadow).
  static const List<BoxShadow> card = <BoxShadow>[];

  /// E2: menus, floating search. Border + subtle shadow.
  static const List<BoxShadow> overlay = <BoxShadow>[_subtle];

  /// E3: sheets, dialogs. Shadow, no border.
  static const List<BoxShadow> modal = <BoxShadow>[_floating];
}
