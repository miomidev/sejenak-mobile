import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/root/sejenak_color.dart';
import '../../services/proposal/proposal_service.dart';

class ProposalScreen extends StatefulWidget {
  @override
  _ProposalScreenState createState() => _ProposalScreenState();
}

class _ProposalScreenState extends State<ProposalScreen> {
  final ProposalService _proposalService = ProposalService();
  bool _isLoading = false;
  File? _selectedFile;
  Map<String, dynamic>? _myProposal;

  @override
  void initState() {
    super.initState();
    _fetchMyProposal();
  }

  Future<void> _fetchMyProposal() async {
    setState(() => _isLoading = true);
    final result = await _proposalService.getMyProposal();
    setState(() {
      _myProposal = result['data'];
      _isLoading = false;
    });
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitProposal() async {
    if (_selectedFile == null) return;

    setState(() => _isLoading = true);
    final result = await _proposalService.submitProposal(_selectedFile!.path);
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
      ),
    );

    if (result['success']) {
      _fetchMyProposal(); // Refresh status
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SejenakText(
          text: 'Daftar Konselor',
          type: SejenakTextType.h5,
          fontWeight: FontWeight.bold,
          color: SejenakColor.white,
        ),
        backgroundColor: SejenakColor.light,
        elevation: 0,
        iconTheme: IconThemeData(color: SejenakColor.white),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: _myProposal != null 
              ? _buildStatusView()
              : _buildSubmitView(),
          ),
    );
  }

  Widget _buildStatusView() {
    String status = _myProposal!['status'] ?? 'pending';
    Color statusColor = status == 'approved' ? Colors.green 
                     : (status == 'rejected' ? Colors.red : Colors.orange);
    String statusText = status == 'approved' ? 'Diterima' 
                     : (status == 'rejected' ? 'Ditolak' : 'Menunggu Review');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          status == 'approved' ? Icons.check_circle_outline_rounded 
          : (status == 'rejected' ? Icons.cancel_outlined 
          : Icons.access_time_rounded),
          size: 80,
          color: statusColor,
        ),
        SizedBox(height: 20),
        SejenakText(
          text: 'Status Pengajuan:',
          type: SejenakTextType.regular,
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: SejenakText(
            text: statusText,
            type: SejenakTextType.h5,
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
        SizedBox(height: 30),
        SejenakText(
          text: status == 'pending' 
            ? 'Tim kami sedang mereview dokumen pengajuan Anda. Harap tunggu konfirmasi lebih lanjut.' 
            : (status == 'approved' ? 'Selamat! Anda sekarang adalah Konselor.' : 'Maaf, pengajuan Anda ditolak.'),
          type: SejenakTextType.small,
          color: SejenakColor.stroke,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubmitView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SejenakText(
          text: 'Bergabung sebagai Konselor',
          type: SejenakTextType.h4,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: 12),
        SejenakText(
          text: 'Unggah CV atau sertifikat Anda (PDF, DOC) untuk kami tinjau.',
          type: SejenakTextType.regular,
          color: SejenakColor.stroke,
        ),
        SizedBox(height: 30),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: SejenakColor.primary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SejenakColor.stroke, style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file_rounded, size: 40, color: SejenakColor.secondary),
                SizedBox(height: 10),
                SejenakText(
                  text: _selectedFile != null 
                    ? _selectedFile!.path.split('/').last 
                    : 'Tap untuk memilih file',
                  type: SejenakTextType.small,
                  color: _selectedFile != null ? SejenakColor.white : SejenakColor.stroke,
                ),
              ],
            ),
          ),
        ),
        Spacer(),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _selectedFile == null ? null : _submitProposal,
            style: ElevatedButton.styleFrom(
              backgroundColor: SejenakColor.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: SejenakText(
              text: 'Kirim Pengajuan',
              type: SejenakTextType.regular,
              fontWeight: FontWeight.bold,
              color: SejenakColor.white,
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
