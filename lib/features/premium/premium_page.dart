import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music_player/data/services/premium/premium_service.dart';
import 'package:music_player/utils/constants/colors.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  final PremiumService _premium = PremiumService.instance;

  Future<void> _subscribe() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: FColors.darkContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Processing payment',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: FColors.textWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Row(
            children: [
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: FColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please wait… we are confirming your subscription.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: FColors.textWhite.withValues(alpha: 0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startMockPurchase() async {
    try {
      // Show dialog then run purchase, then close.
      unawaited(_subscribe());
      await _premium.purchasePremiumMock();
      if (!mounted) return;
      Navigator.of(context).pop(); // close dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Premium activated. Ads are now disabled.'),
          backgroundColor: FColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).maybePop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelMock() async {
    try {
      await _premium.cancelPremiumMock();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Premium cancelled. Ads may show again.'),
          backgroundColor: FColors.darkGrey,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Widget _benefitTile({required IconData icon, required String title, required String subtitle}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: FColors.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: FColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: FColors.textWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: FColors.textWhite.withValues(alpha: 0.75),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _premium,
      builder: (context, _) {
        final isPremium = _premium.isPremium;
        final processing = _premium.isProcessing;

        return Scaffold(
          backgroundColor: FColors.black,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [FColors.primaryBackground, Color(0xFF3C1D71)],
                      ),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.workspace_premium, color: FColors.textWhite),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Go Premium',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: FColors.textWhite,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (isPremium)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: FColors.textWhite,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Subscribe to remove ads and unlock the best experience.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: FColors.textWhite.withValues(alpha: 0.8),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Simple rule: if you’re Premium, we won’t show interstitial ads.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: FColors.textWhite.withValues(alpha: 0.72),
                            fontSize: 12.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  _benefitTile(
                    icon: Icons.block,
                    title: 'No ads',
                    subtitle: 'Interstitial ads are disabled while Premium is active.',
                  ),
                  const SizedBox(height: 12),
                  _benefitTile(
                    icon: Icons.bolt,
                    title: 'Better experience',
                    subtitle: 'Smoother navigation and fewer interruptions while listening.',
                  ),
                  const SizedBox(height: 12),
                  _benefitTile(
                    icon: Icons.security,
                    title: 'Synced across devices',
                    subtitle: 'Your Premium status is stored in Firestore for your account.',
                  ),

                  const SizedBox(height: 22),

                  if (!isPremium)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: processing ? null : _startMockPurchase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          processing ? 'Processing…' : 'Subscribe (Mock Payment)',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: processing ? null : _cancelMock,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: FColors.textWhite,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          processing ? 'Please wait…' : 'Cancel Premium (Mock)',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
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
}

