import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'package:selena/app/components/sejenak_primary_button.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/app/partial/main/sejenak_circular.dart';
import 'package:selena/models/journal_models/journal_models.dart';
import 'package:selena/models/post_models/post_models.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:selena/services/comunity/comunity.dart';
import 'package:selena/services/journal/journal.dart';
import 'package:selena/session/user_session.dart';

class SejenakJournal {
  final int? id;
  final String? initialTitle;
  final String? initialContent;
  final VoidCallback? onJournalSaved;
  final ImagePicker _picker = ImagePicker();
  File? image;
  bool isAnonymous = false;
  final TextEditingController titleController = TextEditingController();
  final ComunityServices comunity;

  SejenakJournal({
    this.id,
    this.initialTitle,
    this.initialContent,
    this.onJournalSaved,
  }) : comunity = ComunityServices(UserSession().user!);

  void showJournalView(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: SejenakColor.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 18.0),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back,
                          color: SejenakColor.secondary,
                        ),
                      ),
                      SejenakText(
                        text: "Journal",
                        type: SejenakTextType.h3,
                        color: SejenakColor.secondary,
                      ),
                      GestureDetector(
                        onTap: () => showEditMode(context),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: SejenakColor.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Journal Content View Mode
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Ini untuk alignment kolom
                        children: [
                          // Title
                          Text(
                            initialTitle ?? "Judul Journal",
                            style: TextStyle(
                              fontSize: 28.48,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Exo2',
                              color: SejenakColor.secondary,
                              wordSpacing: 0.4,
                            ),
                            textAlign: TextAlign.left, // Tambahkan ini
                          ),

                          // Content
                          Text(
                            initialContent ??
                                "Konten journal akan ditampilkan di sini...",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Exo2',
                              color: SejenakColor.secondary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.left, // Tambahkan ini
                          ),

                          // Anonymous Badge
                          
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showEditMode(BuildContext context) {
    final quill.QuillController _quillController =
        quill.QuillController.basic();
    final FocusNode _focusNode = FocusNode();
    final ScrollController _scrollController = ScrollController();

    // Initialize values for edit mode
    titleController.text = initialTitle ?? '';

    // Set initial content for quill editor
    if (initialContent != null && initialContent!.isNotEmpty) {
      _quillController.document = quill.Document()..insert(0, initialContent!);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _quillController.addListener(() {
              setState(() {});
            });

            return Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: SejenakColor.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        children: [
                          SizedBox(height: 18),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Icon(
                                  Icons.cancel_outlined,
                                  color: SejenakColor.secondary,
                                ),
                              ),
                              Spacer(),
                              // Anonymous Toggle
                              // GestureDetector(
                              //   onTap: () {
                              //     setState(() {
                              //       isAnonymous = !isAnonymous;
                              //     });
                              //   },
                              //   child: Container(
                              //     padding: EdgeInsets.symmetric(
                              //         horizontal: 12, vertical: 6),
                              //     decoration: BoxDecoration(
                              //       color: isAnonymous
                              //           ? SejenakColor.primary
                              //           : Colors.grey[300],
                              //       borderRadius: BorderRadius.circular(20),
                              //       border: Border.all(
                              //         color: isAnonymous
                              //             ? SejenakColor.secondary
                              //             : Colors.grey,
                              //       ),
                              //     ),
                              //     child: Row(
                              //       children: [
                              //         Icon(
                              //           Icons.visibility_off,
                              //           size: 16,
                              //           color: isAnonymous
                              //               ? SejenakColor.white
                              //               : Colors.grey,
                              //         ),
                              //         SizedBox(width: 4),
                              //         Text(
                              //           'Anonymous',
                              //           style: TextStyle(
                              //             fontSize: 12,
                              //             fontWeight: FontWeight.w500,
                              //             color: isAnonymous
                              //                 ? SejenakColor.white
                              //                 : Colors.grey,
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(width: 10),
                            ],
                          ),
                          SizedBox(height: 20),
                          TextField(
                            controller: titleController,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: "Judul Journal...",
                              hintStyle: TextStyle(
                                fontSize: 28.48,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Exo2',
                                color: SejenakColor.secondary.withOpacity(0.6),
                                wordSpacing: 0.4,
                              ),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontSize: 28.48,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Exo2',
                              color: SejenakColor.secondary,
                              wordSpacing: 0.4,
                            ),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  child: quill.QuillEditor(
                                    controller: _quillController,
                                    focusNode: _focusNode,
                                    scrollController: _scrollController,
                                  ),
                                ),
                                if (_quillController.document.isEmpty())
                                  Positioned(
                                    top: -2,
                                    left: 5,
                                    child: IgnorePointer(
                                      child: Text(
                                        "Tulis journal Anda di sini...",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[500],
                                          fontFamily: 'Exo2',
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 80),
                        ],
                      ),
                    ),

                    // Bottom toolbar dengan format yang lebih lengkap
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: SejenakColor.primary,
                              border: Border(
                                top: BorderSide(
                                  width: 1.0,
                                  color: Colors.grey[900]!,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 15.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // Heading options
                                    ...List.generate(5, (index) {
                                      final headingList = [
                                        quill.Attribute.h1,
                                        quill.Attribute.h2,
                                        quill.Attribute.h3,
                                        quill.Attribute.h4,
                                        quill.Attribute.h5,
                                      ];
                                      return GestureDetector(
                                        onTap: () {
                                          _quillController.formatSelection(
                                              headingList[index]);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            "H${index + 1}",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),

                                    SizedBox(width: 10),

                                    // Text formatting options
                                    _buildFormatButton(
                                      Icons.format_bold,
                                      "Bold",
                                      () => _quillController.formatSelection(
                                          quill.Attribute.bold),
                                    ),
                                    _buildFormatButton(
                                      Icons.format_italic,
                                      "Italic",
                                      () => _quillController.formatSelection(
                                          quill.Attribute.italic),
                                    ),
                                    _buildFormatButton(
                                      Icons.format_strikethrough,
                                      "Strikethrough",
                                      () => _quillController.formatSelection(
                                          quill.Attribute.strikeThrough),
                                    ),
                                    _buildFormatButton(
                                      Icons.format_underline,
                                      "Underline",
                                      () => _quillController.formatSelection(
                                          quill.Attribute.underline),
                                    ),

                                    SizedBox(width: 10),

                                    // List options
                                    _buildFormatButton(
                                      Icons.format_list_bulleted,
                                      "Bullet List",
                                      () => _quillController
                                          .formatSelection(quill.Attribute.ul),
                                    ),
                                    _buildFormatButton(
                                      Icons.format_list_numbered,
                                      "Numbered List",
                                      () => _quillController
                                          .formatSelection(quill.Attribute.ol),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Action buttons (Camera and Save)
                    Positioned(
                      bottom: 100,
                      left: 0,
                      right: 5,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // SizedBox(height: 10),
                                // Container(
                                //   child: SejenakPrimaryButton(
                                //     width: 60,
                                //     height: 60,
                                //     text: "",
                                //     action: () async {
                                //       final pickedFile =
                                //           await _picker.pickImage(
                                //               source: ImageSource.gallery);
                                //       if (pickedFile != null) {
                                //         setState(() {
                                //           image = File(pickedFile.path);
                                //         });
                                //       }
                                //     },
                                //     icon: "assets/svg/camera.svg",
                                //   ),
                                // ),
                                SizedBox(height: 10),
                                Container(
                                  child: SejenakPrimaryButton(
                                    width: 100,
                                    height: 50,
                                    text: "Simpan",
                                    action: () => _createOrUpdateJournal(
                                      context,
                                      titleController.text,
                                      _quillController,
                                    ),
                                    // icon: 'assets/svg/save.svg',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFormatButton(IconData icon, String tooltip, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<void> _createOrUpdateJournal(
    BuildContext context,
    String title,
    quill.QuillController quillController,
  ) async {
    try {
      if (title.trim().isEmpty) {
        _showSnackBar(context, "Judul tidak boleh kosong");
        return;
      }

      final String content = quillController.document.toPlainText().trim();
      if (content.isEmpty) {
        _showSnackBar(context, "Konten journal tidak boleh kosong");
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (context) => const Center(
          child: SejenakCircular(),
        ),
      );

      final now = DateTime.now().toIso8601String();

      final journal = JournalModels(
        entriesId: id,
        title: title.trim(),
        content: content,
        createdAt: id == null ? now : null,
        updatedAt: now,
      );

      final journalService = JournalApiService();

      if (id != null) {
        await journalService.updateJournal(journal);
      } else {
        await journalService.createJournal(journal);
      }

      // Close dialogs and modals
      Navigator.pop(context); // Close loading
      Navigator.pop(context); // Close edit modal
      // Navigator.pop(context); // Close view modal
      if (onJournalSaved != null) {
        onJournalSaved!();
      }
      _showSnackBar(context,
          id != null ? "Journal berhasil diupdate" : "Journal berhasil dibuat",
          isError: false);
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      _showSnackBar(context,
          "Gagal ${id != null ? 'mengupdate' : 'membuat'} journal: $e");
      print("Error ${id != null ? 'updating' : 'creating'} journal: $e");
    }
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
