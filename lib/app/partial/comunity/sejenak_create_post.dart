import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'package:selena/app/components/sejenak_primary_button.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/app/partial/main/sejenak_circular.dart';
import 'package:selena/models/post_models/post_models.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:selena/services/comunity/comunity.dart';
import 'package:selena/session/user_session.dart';

class SejenakCreatePost {
  final int? id; // Null untuk create, ada value untuk edit
  late bool isCreate;
  final String? initialTitle;
  final String? initialContent;
  final String? initialImage;
  final bool? initialIsAnonymous;
  final ImagePicker _picker = ImagePicker();
  File? image;
  bool isAnonymous = false;
  final TextEditingController commentInput = TextEditingController();
  final headingList = [
    quill.Attribute.h1,
    quill.Attribute.h2,
    quill.Attribute.h3,
    quill.Attribute.h4,
    quill.Attribute.h5,
  ];
  
  late final ComunityServices comunity;

SejenakCreatePost({
  this.id,
  this.initialTitle,
  this.initialContent,
  this.initialImage,
  this.initialIsAnonymous,
  this.isCreate = false
}) {
  final user = UserSession().user;
  if (user == null) {
    throw Exception("User belum login, tidak bisa membuat post!");
  }
  comunity = ComunityServices(user);
}


  void showCreateContainer(BuildContext context) {
    final quill.QuillController _quillController = quill.QuillController.basic();
    final FocusNode _focusNode = FocusNode();
    final ScrollController _scrollController = ScrollController();

    // Initialize values for edit mode
    if (id != null) {
      commentInput.text = initialTitle ?? '';
      isAnonymous = initialIsAnonymous ?? false;
      // Set initial content for quill editor
      if (initialContent != null && initialContent!.isNotEmpty) {
        _quillController.document = quill.Document()..insert(0, initialContent!);
      }
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
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isAnonymous = !isAnonymous;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isAnonymous
                                        ? SejenakColor.primary
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isAnonymous
                                          ? SejenakColor.secondary
                                          : Colors.grey,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.visibility_off,
                                        size: 16,
                                        color: isAnonymous
                                            ? SejenakColor.white
                                            : Colors.grey,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Anonymous',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isAnonymous
                                              ? SejenakColor.white
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              // Tombol Post/Update di header
                              Container(
                                child: SejenakPrimaryButton(
                                  width: 100,
                                  height: 40,
                                  text: id != null ? "Update" : "Post",
                                  action: () => _createOrUpdatePost(
                                    context,
                                    commentInput.text,
                                    _quillController,
                                  ),
                                  icon: 'assets/svg/play.svg',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          TextField(
                            controller: commentInput,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: "Judul...",
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
                                // Fallback placeholder untuk kasus tertentu
                                if (_quillController.document.isEmpty())
                                  Positioned(
                                    top: -2,
                                    left: 5,
                                    child: IgnorePointer(
                                      child: Text(
                                        "Tulis sesuatu...",
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

                    // Bottom toolbar
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
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: List.generate(
                                  headingList.length,
                                  (index) => GestureDetector(
                                    onTap: () {
                                      _quillController
                                          .formatSelection(headingList[index]);
                                    },
                                    child: SejenakText(
                                      text: "H${index + 1}",
                                      type: SejenakTextType.regular,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
                                // Preview image untuk edit mode atau image yang dipilih
                                if (image != null || (id != null && initialImage != null))
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1.0,
                                        color: Colors.grey[900]!,
                                      ),
                                      color: SejenakColor.secondary,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        const BoxShadow(
                                          color: SejenakColor.black,
                                          spreadRadius: 0.2,
                                          blurRadius: 0,
                                          offset: Offset(0.1, 4),
                                        ),
                                      ],
                                      image: DecorationImage(
                                        image: image != null 
                                            ? FileImage(image!)
                                            : NetworkImage(initialImage!) as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Delete image button
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                image = null;
                                              });
                                            },
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                SizedBox(height: 10),
                                Container(
                                  child: SejenakPrimaryButton(
                                    width: 60,
                                    height: 60,
                                    text: "",
                                    action: () async {
                                      final pickedFile =
                                          await _picker.pickImage(
                                              source: ImageSource.gallery);
                                      if (pickedFile != null) {
                                        setState(() {
                                          image = File(pickedFile.path);
                                        });
                                      }
                                    },
                                    icon: "assets/svg/camera.svg",
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

  // Fungsi untuk membuat atau mengupdate post
  Future<void> _createOrUpdatePost(
    BuildContext context,
    String title,
    quill.QuillController quillController,
  ) async {
    try {
      // Validasi input
      if (title.trim().isEmpty) {
        _showSnackBar(context, "Judul tidak boleh kosong");
        return;
      }

      final String content = quillController.document.toPlainText().trim();
      if (content.isEmpty) {
        _showSnackBar(context, "Konten tidak boleh kosong");
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

      // Create atau Update PostModels object
      final PostModels post = PostModels(
        postId: id,
        title: title,
        deskripsiPost: content,
        postPicture: image?.path ?? initialImage, // Gunakan image baru atau existing
        isAnonymous: isAnonymous,
      );

      if (isCreate == false) {
        await comunity.updatePost(post);
      } else {
        await comunity.createPost(post);
      }

      // Close loading and modal
      Navigator.pop(context); // Close loading
      Navigator.pop(context); // Close modal

      _showSnackBar(
        context, 
        id != null ? "Post berhasil diupdate" : "Post berhasil dibuat", 
        isError: false
      );

      // Clear form hanya untuk create mode
      if (id == null) {
        commentInput.clear();
        quillController.clear();
        image = null;
        isAnonymous = false;
      }

    } catch (e) {
      Navigator.pop(context); // Close loading jika ada error
      _showSnackBar(context, "Gagal ${id != null ? 'mengupdate' : 'membuat'} post: $e");
      print("Error ${id != null ? 'updating' : 'creating'} post: $e");
    }
  }

  // Helper function untuk menampilkan snackbar
  void _showSnackBar(BuildContext context, String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
}