import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/gift.dart';
import '../../data/product_search_service.dart';

class GiftDetailsDialog extends StatelessWidget {
  final Gift gift;

  const GiftDetailsDialog({
    super.key,
    required this.gift,
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shoppingLinks = ProductSearchService.getAllShoppingLinks(gift.name, gift.price);
    final productOptions = ProductSearchService.getSpecificProductRecommendations(gift.name);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gift image and name
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  // Gift Image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: gift.imageUrl != null
                          ? Image.network(
                              gift.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.card_giftcard,
                                  size: 30,
                                  color: Theme.of(context).primaryColor,
                                );
                              },
                            )
                          : Icon(
                              Icons.card_giftcard,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gift.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          gift.price,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gift Description
                    Text(
                      gift.pitch,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Specific Product Recommendations
                    if (productOptions.isNotEmpty) ...[
                      Text(
                        '🛍️ Specific Products',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...productOptions.map((product) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.shopping_bag, color: Colors.green),
                          title: Text(product['name']!),
                          subtitle: Text('${product['price']} • ${product['store']}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _launchUrl(product['link']!),
                        ),
                      )),
                      const SizedBox(height: 20),
                    ],
                    
                    // Shopping Links
                    Text(
                      '🔍 Search & Compare',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Amazon
                    _buildShoppingButton(
                      context,
                      'Amazon',
                      'Search on Amazon with price filter',
                      Icons.shopping_cart,
                      Colors.orange,
                      shoppingLinks['Amazon']!,
                    ),
                    
                    // Google Shopping
                    _buildShoppingButton(
                      context,
                      'Google Shopping',
                      'Compare prices across stores',
                      Icons.compare_arrows,
                      Colors.blue,
                      shoppingLinks['Google Shopping']!,
                    ),
                    
                    // eBay
                    _buildShoppingButton(
                      context,
                      'eBay',
                      'Find deals and auctions',
                      Icons.gavel,
                      Colors.blue[800]!,
                      shoppingLinks['eBay']!,
                    ),
                    
                    // Etsy
                    _buildShoppingButton(
                      context,
                      'Etsy',
                      'Handmade and unique items',
                      Icons.favorite,
                      Colors.orange[700]!,
                      shoppingLinks['Etsy']!,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingButton(
    BuildContext context,
    String storeName,
    String description,
    IconData icon,
    Color color,
    String url,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: () => _launchUrl(url),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          padding: const EdgeInsets.all(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new, color: color, size: 16),
          ],
        ),
      ),
    );
  }
} 