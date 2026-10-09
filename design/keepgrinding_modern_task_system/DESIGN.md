---
name: KeepGrinding Modern Task System
colors:
  surface: '#f9f9ff'
  surface-dim: '#cfdaf2'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eeff'
  surface-container-high: '#dee8ff'
  surface-container-highest: '#d8e3fb'
  on-surface: '#111c2d'
  on-surface-variant: '#43493d'
  inverse-surface: '#263143'
  inverse-on-surface: '#ecf1ff'
  outline: '#74796b'
  outline-variant: '#c3c8b9'
  surface-tint: '#466728'
  primary: '#436526'
  on-primary: '#ffffff'
  primary-container: '#5b7e3c'
  on-primary-container: '#f7ffe8'
  inverse-primary: '#abd286'
  secondary: '#8b5000'
  on-secondary: '#ffffff'
  secondary-container: '#fe9c22'
  on-secondary-container: '#673b00'
  tertiary: '#ae262c'
  on-tertiary: '#ffffff'
  tertiary-container: '#d03f41'
  on-tertiary-container: '#fffaf9'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#c6efa0'
  primary-fixed-dim: '#abd286'
  on-primary-fixed: '#0d2000'
  on-primary-fixed-variant: '#2f4f12'
  secondary-fixed: '#ffdcbe'
  secondary-fixed-dim: '#ffb870'
  on-secondary-fixed: '#2c1600'
  on-secondary-fixed-variant: '#693c00'
  tertiary-fixed: '#ffdad7'
  tertiary-fixed-dim: '#ffb3af'
  on-tertiary-fixed: '#410005'
  on-tertiary-fixed-variant: '#900b1a'
  background: '#f9f9ff'
  on-background: '#111c2d'
  surface-variant: '#d8e3fb'
typography:
  headline-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 40px
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 10px
    fontWeight: '700'
    lineHeight: 14px
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system channels an optimistic, highly tactile, and approachable productivity ethos. The visual language merges modern minimalism with playful tactile softness—characterized by organic pill containers, generous whitespace, friendly rounded corners, and lively color blocking for task status discrimination.

The emotional core is lighthearted focus: eliminating task anxiety through approachable pastel-to-vibrant color transitions, airy off-white surfaces, and cheerful iconography. Instead of sterile corporate task lists, this system prioritizes dopamine-driven completion through cheerful status cards, smooth progress tracks, and clean typography.

## Colors

The palette balances grounding botanical greens with warm, communicative accent tones.

- **Primary (`#5B7E3C` - Forest Green):** Anchors success states, verified completions, and primary balanced action accents.
- **Secondary (`#FF9D23` - Vibrant Orange):** Represents active work, warnings, and pending deadlines.
- **Tertiary (`#EA5252` - Coral Red):** Drives urgent priorities, high-importance badges, and overdue triggers.
- **Accent Warm Yellow (`#FFD65A`):** Used for in-progress highlights, category chips, and spotlighting daily counts.
- **Neutrals & Surfaces:** Pure White (`#FFFFFF`) for elevated task cards, Soft Cream Tint (`#F8F9FA`) for the root canvas, Slate Navy (`#1E293B`) for prominent display titles, and Muted Slate (`#64748B`) for secondary timestamps and metadata.

## Typography

The typography leverages `Plus Jakarta Sans` across all display scales. Its rounded geometric construction, wide apertures, and clean stroke distribution echo the soft, welcoming visual identity seen in contemporary productivity interfaces.

- **Headlines:** Set with extra bold and bold weights (`700` and `800`) to create high-contrast scanning hierarchy against pale background cards.
- **Body:** Uses regular and medium cuts (`400` and `500`) with generous line heights to preserve clarity on compact mobile screens.
- **Labels & Badges:** Utilize heavier weights (`600` and `700`) in smaller point sizes for status indicators, calendar headers, and progress stamps.

## Layout & Spacing

This mobile-first layout relies on vertical rhythm and horizontal overflow strips. Designed natively for compact viewports (360px–430px wide), the screen utilizes a 4-column base structure with generous margins.

- **Outer Canvas:** A consistent 20px (`1.25rem`) padding keeps tap targets away from hardware edges.
- **Vertical Rhythm:** Sections and task timeline groups align across 16px to 24px intervals (`space-md` to `space-lg`).
- **Interactive Stacks:** List items inside chronological feeds use tight 12px to 16px vertical gaps, coupled with connected track lines for timeline steps.

## Elevation & Depth

Elevation avoids heavy, muddy drop shadows in favor of soft, diffused ambient light and warm tinted casts.

- **Base Canvas:** Flat `#F8F9FA`.
- **Card Surfaces:** Pure `#FFFFFF` cards elevated via `0 10px 25px -5px rgba(30, 41, 59, 0.05), 0 4px 6px -2px rgba(30, 41, 59, 0.02)`.
- **Active Task Cards:** Tinted cards (e.g., coral, mustard, or sage containers) utilize low-opacity colored glows reflecting their base hue: `0 12px 20px -4px rgba(234, 82, 82, 0.25)`.
- **Timeline Rails:** Inset hairline connecting rails rendered in `#E2E8F0` overlaid with circular status nodes.

## Shapes

The design system embraces a high-radius, pill-centric geometry (Level 3). 

- **Primary Actions & Badges:** True continuous pill curves (`rounded-full` / 9999px radius).
- **Task & Calendar Cards:** Plump, comfortable corners with 20px to 24px radii (`rounded-2xl`).
- **Search Bars & Input Pills:** Fully rounded capsule perimeters.
- **Avatars & Status Indicators:** Concentric circular geometries.

## Components

### Buttons
- **Primary Action (e.g., "+ Add Task"):** Capsule pill shaped (`rounded-full`), solid background, white text (`label-lg`), with subtle directional elevation.
- **Icon Actions:** Circular 44x44px touch targets in white or low-contrast light slate tint with centered vector glyphs.

### Task Cards
- **Overview Cards (Carousel):** Vibrant solid or soft pastel backgrounds (`#EA5252`, `#5B7E3C`, `#FF9D23`), white typography, inline mini progress bars with pill tracks, and category emoji accents.
- **Timeline List Items:** White or pale tinted surfaces, soft borders or no borders, bold task title on the left, right-aligned time stamps in muted slate (`#64748B`), and an attached timeline connector node.

### Category & Status Chips
- **Circular Category Tokens:** 56x56px soft circular pads containing centered icons (e.g., red for "To-Do", yellow for "Progress", green for "Done") with compact labels beneath.
- **Metadata Badges:** Compact pill tags with 6px horizontal padding and bold uppercase status labels.

### Inputs & Search
- **Search Bar:** Pill-shaped text box with an inset magnifying icon, `#F1F5F9` or pure white fill with ambient drop shadow, and placeholder text in `#94A3B8`.

### Timeline & Progress
- **Timeline Strip:** Vertical line anchored by circular indicator dots that switch from solid rings to filled status nodes depending on completion.
- **Progress Track:** 6px pill tracks featuring white or high-contrast fill progress indicators with soft rounded caps.