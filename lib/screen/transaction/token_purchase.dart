import 'package:flutter/material.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/transaction/transaction_service.dart';

class TokenPurchaseScreen extends StatefulWidget {
  @override
  _TokenPurchaseScreenState createState() => _TokenPurchaseScreenState();
}

class _TokenPurchaseScreenState extends State<TokenPurchaseScreen> {
  final TransactionService _transactionService = TransactionService();
  bool _isLoading = false;

  List<dynamic> _packages = [];

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    setState(() => _isLoading = true);
    final packages = await _transactionService.getTokenPackages();
    setState(() {
      _packages = packages;
      _isLoading = false;
    });
  }

  Future<void> _buyPackage(Map<String, dynamic> package) async {
    setState(() => _isLoading = true);
    
    final result = await _transactionService.checkout(
      package['name'], 
      package['token_amount'], 
      package['price']
    );
    
    setState(() => _isLoading = false);

    if (result['success']) {
      final paymentUrl = result['payment_url'];
      if (paymentUrl != null && await canLaunchUrl(Uri.parse(paymentUrl))) {
        await launchUrl(Uri.parse(paymentUrl), mode: LaunchMode.externalApplication);
      } else if (result['qris_url'] != null) {
        // Show QRIS in a dialog
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: SejenakText(text: 'Scan QRIS', type: SejenakTextType.h5, fontWeight: FontWeight.bold),
            content: Image.network(result['qris_url']),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Tutup"),
              )
            ],
          )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tautan pembayaran tidak tersedia.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal membuat transaksi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SejenakText(
          text: 'Beli Token',
          type: SejenakTextType.h5,
          fontWeight: FontWeight.bold,
          color: SejenakColor.dark,
        ),
        backgroundColor: SejenakColor.light,
        elevation: 0,
        iconTheme: IconThemeData(color: SejenakColor.dark),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: SejenakColor.secondary))
        : _packages.isEmpty 
          ? Center(
              child: SejenakText(
                text: "Belum ada paket token tersedia.",
                type: SejenakTextType.regular,
                color: SejenakColor.stroke,
              ),
            )
          : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _packages.length,
            itemBuilder: (context, index) {
              final package = _packages[index];
              return Card(
                color: SejenakColor.primary,
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: SejenakColor.secondary.withOpacity(0.2),
                    child: Icon(Icons.monetization_on_rounded, color: SejenakColor.secondary),
                  ),
                  title: SejenakText(
                    text: package['name'],
                    type: SejenakTextType.regular,
                    fontWeight: FontWeight.bold,
                  ),
                  subtitle: SejenakText(
                    text: '${package['token_amount']} Token',
                    type: SejenakTextType.small,
                    color: SejenakColor.stroke,
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _buyPackage(package),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SejenakColor.secondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: SejenakText(
                      text: 'Rp ${package['price']}',
                      type: SejenakTextType.small,
                      color: SejenakColor.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }
}
