---
name: epub-curator
description: >-
  Curate, audit, clean, repair, compare, and organize EPUB books. Use when
  asked to check or fix EPUBs, validate EPUBCheck conformance, diagnose
  rendering issues on Kobo or Tolino, inspect missing or low-quality covers,
  replace duplicate editions, split or retire omnibus volumes, plan reading
  orders, or create optional Kobo KEPUB derivatives. Diagnose first, present
  one consolidated selection of changes, then apply only selected work.
---

# EPUB curator

Produce reliable, readable EPUBs without losing unique text, artwork, or metadata. Prioritize compatibility with strict readers, including Tolino Vision 6 and Kobo Clara BW/Color. Use the current project's own instructions for naming, metadata, logs, storage layout, and series policy; do not impose one library's conventions on another.

## Intake and decision boundary

1. Resolve the requested scope to actual EPUB paths. Identify existing curated files, incoming sources, and any non-EPUB formats separately. Do not search hidden or unrelated directories without a reason.
2. Inventory sources **without changing them**. Unpack only into a uniquely named work directory you own; reject unsafe ZIP paths (`..`, absolute paths, symlink escapes). Do not use a directory already holding imported books as disposable scratch space.
3. Run the full audit, then show per-book findings, affected counts, uncertainties, and a **single consolidated menu**: technical fixes, metadata, cover alternatives, retained/retired editions, promotional pages, and renames. Present the text of any promotional page before offering its removal. Recommend defaults, but wait for the user's selection before altering originals, deleting content, fetching cover art, or replacing editions.
4. Once the user selects, carry out that selection without seeking per-file permission. If an unexpected loss of unique content, ambiguous ownership, or an invalid replacement is discovered, stop that item and report it rather than guessing; finish independent selected items when safe.
5. Keep original sources until their disposition is explicitly selected. Remove only **your own, precisely identified scratch directories** after work, even on failure. Never delete an entire shared `temp/` or staging folder by default.

For a check-only request, stop after the audit and report. Never silently "fix" books that were only to be assessed.

## Optional Kobo KEPUB derivatives

At project/library intake, offer KEPUB **once** as an optional companion format for Kobo devices. Record the choice in that project's conventions where appropriate and follow it for subsequent cleanup batches unless the user changes it. An unanswered offer is not consent: make only canonical EPUBs. Do not convert on check-only requests, bulk-convert an existing library without separate approval, or prescribe a universal folder layout. Keep the project's storage and naming policy separate from this portable procedure.

Kobo's [EPUB Guidelines](https://github.com/kobolabs/epub-spec/blob/master/README.md) describe EPUB production and sideload testing, **not** a complete KEPUB conversion specification. On Kobo eInk devices, sideloaded `.epub` uses the ADE renderer; `.kepub.epub` invokes Kobo's renderer (`.fxl.kepub.epub` for fixed-layout testing). The guidelines warn that sideloading by extension may disable bookmarks/notes and omit cover thumbnails in their testing workflow. Do not infer the same outcome for every converted book, firmware version, or transfer method: test those features on the target device.

When a project has opted in and books are in an approved cleanup scope:

1. Use the **final, EPUBCheck-validated EPUB** as the immutable source. Do not convert an unapproved or broken incoming file, overwrite the source, or treat a KEPUB as the canonical edition.
   **The source must be EPUB 3.** kepubify always injects EPUB 3-only markup (for example `properties="cover-image"` on the OPF item and a `class` on an injected `<style>`), so a KEPUB derived from an EPUB 2 source can never pass EPUBCheck. In a project that has opted in to KEPUB, offer to migrate every EPUB 2 book in scope to EPUB 3 as a selectable canonical fix (see *EPUB 2 → EPUB 3 migration*); do not relax the derivative's validation instead.
2. Convert with [kepubify](https://pgaskin.net/kepubify/docs/) for a standalone workflow, or use an existing Calibre/KoboTouchExtended workflow if the project prefers it. Confirm the installed tool's options before running it; kepubify supports `--output` and normally emits `.kepub.epub`. Choose a separate destination explicitly, avoid accidental `_converted` directories or filename collisions, and avoid optional text/CSS rewrites unless requested. **Do not just rename** an EPUB as a substitute for conversion.
3. Validate the **actual derived file** with official EPUBCheck and the ZIP/OPF, manifest/spine, navigation, cover, metadata, font, and text checks above. Resolve conversion-introduced errors; review warnings. Compare the title, creator, series metadata, reading content, cover, and chapter order with the canonical EPUB. Keep a failed candidate separate; never replace the good EPUB to make the derivative pass.
4. Sideload a representative KEPUB on the target Kobo and inspect chapter navigation, cover thumbnail, font switching, text visibility, bookmarks, notes, and resume position. Kobo recommends an OPF-declared cover in its own XHTML document using an image element, usable NCX/EPUB 3 navigation, and caution with CSS/fonts. EPUBCheck does not guarantee device behavior; disclose untested features rather than promising them.

**Series is a separate device step.** Conversion alone does not guarantee a populated Kobo Series tab or correct order. After the Kobo imports the book, a user-approved Calibre/KoboTouch metadata sync, `seriesmeta`, or NickelSeries may be needed to populate device-side series data; verify the result on the device. Back up the device database before direct edits, do not modify it without consent, and keep canonical `dc:title` clean. See the [kepubify seriesmeta documentation](https://pgaskin.net/kepubify/docs/#seriesmeta) for one supported route.

## Full EPUB audit

Inspect every selected file; do not infer quality from its filename or cover pixel count alone.

- **ZIP and structure:** `mimetype` must be the first ZIP member, stored uncompressed, with bytes exactly `application/epub+zip`. `META-INF/container.xml` must resolve to an existing OPF. Check ZIP integrity, OPF `<manifest>` and `<spine>`, every manifest target, every spine ID, and content files missing from the manifest. Resolve `href` relative to the OPF, including URL decoding and fragments.
- **Text integrity:** check `.xhtml`, `.html`, `.xml`, `.css`, `.opf`, and `.ncx` for CRLF/bare CR and UTF-8 BOM. Parse **all** XML-based content files as XML, not just a sample; repair named HTML entities not valid in XML (e.g. `&nbsp;`, `&shy;`) carefully without changing text. Report malformed files and remaining external dependencies.
- **Fonts:** inspect every `@font-face` `src` and referenced font file, style/weight coverage, manifest media types, and CSS/inline `font-family` usage. A face with no working `src` can make text disappear on strict readers. Prefer a hybrid fix: remove body font faces/files/manifest items and explicit `font-family` from body, paragraphs and inherited reading-text spans; retain intact decorative heading/drop-cap faces. Alternatively obtain complete compatible font variants **only with a legitimate source**, or strip all embedded fonts. Do not replace removed reading-font declarations with `serif`/`sans-serif`: an explicit family can defeat the reader's font control. Check unused faces and styles as well as missing variants.
- **TOC:** check NCX and XHTML navigation targets, including fragments; renumber NCX `playOrder` sequentially if used. If removing content, also remove its spine, manifest, NCX, and XHTML-TOC entries, then check every remaining destination.
- **Covers:** require an existing, readable image declared by EPUB 2 `<meta name="cover" content="id">`, EPUB 3 manifest `properties="cover-image"`, or a verified cover manifest ID; a missing cover is a hard failure, not a reason to skip other checks. Confirm media type, dimensions, aspect ratio, compression artifacts, legibility, crop, and correct book/edition. No universal resolution threshold proves quality.
- **Promotional content:** search filenames and rendered text for marketing/newsletter/lastpage/advertising pages. Show their contents in the report and offer removal; do not confuse publisher copyright or title pages with advertisements.
- **Bibliography and metadata:** inspect creator display and sort name, plain title, language, identifiers, series/collection and position. Verify order and translation against title pages or reliable sources; do not assume omnibus titles or publisher numbering correspond to actual works. Mark uncertain publication dates and chronology as approximate.

## EPUBCheck conformance gate

Use the **official [W3C EPUBCheck](https://github.com/w3c/epubcheck)** on each complete, packaged EPUB: during diagnosis to identify conformance defects, and again **after the last edit and repack, before installing or replacing the curated copy**. Use a current production-ready release from the official releases page, with a compatible local Java runtime, or a trusted package of that tool; verify the version and CLI options with `--help`. Do not upload private books to an online validator. For example, with the official distribution's `epubcheck.jar`:

```sh
java -jar /path/to/epubcheck.jar --help
java -jar /path/to/epubcheck.jar "/path/to/book.epub" --json "/path/to/report.json"
```

Keep the report outside the EPUB and distinguish **fatal/errors**, **warnings**, and informational/usage messages; do not suppress a severity to manufacture a pass. Diagnose message IDs and exact resource locations, fix the root cause, repack, and rerun. Validate against the EPUB version the OPF actually declares; do not upgrade EPUB 2 or remove metadata merely to silence a diagnostic without checking reader compatibility and the relevant specification. Migrating EPUB 2 to EPUB 3 is a deliberate fix — required as the KEPUB source and appropriate for a failing EPUB 2 book — never a bare change of the OPF `version` attribute. The official validator covers more than the manual checklist (schemas, cross-resource references, CSS, accessibility-related constraints, media types, and version-specific rules); a handcrafted approximation cannot certify equivalent conformance.

**Acceptance:** zero EPUBCheck fatal/error diagnostics on the *final packaged file* and no unexamined warnings. Fix actionable warnings where possible; record and disclose remaining non-blocking warnings with their IDs and reason. If EPUBCheck cannot run, fails, or reports unresolved errors, do **not** mark the EPUB conformant or silently replace a valid original; keep the candidate and report the blocker. Run the independent reader/curation checks too: an EPUBCheck pass alone does not establish a good cover, usable reading font, accurate metadata, complete omnibus coverage, or correct rendering on a specific device.

### EPUB 2 → EPUB 3 migration

Migrate on a separate candidate and keep the original until the candidate passes. A real migration, not a version bump, includes:

- OPF `version="3.0"`; move `opf:file-as`/`opf:role` to `refines` metas on creators with an `id`; keep a valid `dc:identifier` referenced by `unique-identifier`; add `dcterms:modified` as a UTC timestamp; mark the cover image with `properties="cover-image"`.
- An EPUB 3 navigation document (`properties="nav"`, default XHTML namespace plus `xmlns:epub`, `epub:type="toc"`) whose links follow **spine order**; if the spine itself is out of reading order, restore it. Optionally keep the NCX, consistent with the nav.
- XHTML content valid under HTML5 rules: replace named HTML entities with numeric references, and modernize obsolete markup (for example bare `<col>` → inside `<colgroup>`, `width`/`align`/`valign` → CSS) without changing text.
- Keep series metadata in both Calibre and EPUB 3 `belongs-to-collection` form.
- Verify reading text, assets and cover are unchanged; then require EPUBCheck to pass on the migrated EPUB **and**, where KEPUB is in use, on its converted derivative. Report missing content rather than inventing it.

## Compare covers, editions, and omnibuses

- Group identical ZIP files, then compare actual reading text, spine, TOC, language, translation/edition, and cover for remaining candidates. Identical cover checksums do not prove identical books; matching titles do not prove identical text.
- Build a contents inventory for each omnibus or anthology. Compare individual works **and every story** against proposed replacements, including alternate translated titles. Keep any volume with unique content, even if much of it duplicates other books. Prefer complete, well-formed single-work EPUBs when they fully cover an omnibus; preserve a unique anthology instead of inventing missing books.
- For each cover, compare visible previews at a common display size and native resolution. Only use art matching the specific work; distinguish scans of old editions from a different work. If the curated EPUB has better text/metadata, transfer **only** a suitable cover instead of reverting its cleanup. Keep image references, manifest, cover declaration, title/cover page, and image media type consistent.
- Within a series, keep covers from one design identity (print run/edition); a larger image in a different design is not an upgrade unless the whole series moves with it. Reject placeholders, retailer/text-only covers and tie-in art unless requested. For a multi-book cover change, show a before/after sheet per series and get approval per series.
- Search/download external covers only when the user selected that task, and confirm provenance and permission; do not send book text or private data to third parties. Record unresolved matches rather than taking an unrelated or merely larger image.
- For a multi-cycle reading order, separate story-time order from original publication year, distinguish an omnibus from its constituent books, disclose overlaps and missing works, and link to files that actually exist. Do not merge unrelated series into a fictitious common chronology.

## Apply, repack, verify

Apply approved content removals and TOC/manifest cleanup first; then XML/entities, BOM and LF normalization, fonts, covers, and metadata. Preserve all unrelated assets and intentional decorative styling. Re-read the OPF and sample reading text before packing.

Repack to a **new output path**, not directly over the sole original. Use the OPF root found in `container.xml` (not an assumed `OEBPS` folder); include only declared EPUB content, `META-INF`, and `mimetype`, excluding backups and work artifacts:

```sh
cd "$workdir"
zip -X0 "$output" mimetype
zip -Xr9 "$output" META-INF "$content_root" -x '.git/*'
```

If the content root is the archive root or multiple roots exist, explicitly enumerate the required members instead of adding `.` blindly. On other platforms, use a ZIP library with equivalent first-entry/stored behavior. Validate the output ZIP before replacing the curated copy: CRC, first/stored `mimetype` bytes, container/OPF, manifest and spine, all XHTML/XML, navigation targets and ordering, cover declaration/image, LF/BOM, font references, book metadata, and the expected retained content. **Run EPUBCheck on this exact output and satisfy the conformance gate above before replacing the curated copy.** Check that the library still has each unique work/story once or more. Replace files atomically where possible; preserve originals or incoming sources according to the agreed disposition. Record results in the project's chosen log, if any.
