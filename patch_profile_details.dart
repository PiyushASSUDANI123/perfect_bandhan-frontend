import 'dart:io';

void main() {
  var file = File('lib/widgets/profile_details_sheet.dart');
  var content = file.readAsStringSync();

  // Find the exact block we want to replace
  // constraints: const BoxConstraints(maxWidth: 800),
  // child: Column(

  var targetStr = '''            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // Slide Bar / Drag Handle
                const SizedBox(height: 12.0),
                Center(
                  child: Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.glassBorderColor,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
    
                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Photo Carousel / Premium Bento Hero Card
                          const SizedBox(height: 12.0),
                          _buildPhotoCarousel(size),
                          const SizedBox(height: 20.0),
    
                          // Match Rate & Compatibility Tag
                          _buildHeaderSection(),
                          const SizedBox(height: 24.0),
    
                          // Bento Blocks Layout
                          _buildBentoBlocks(isDesktop),
                          const SizedBox(height: 24.0),

                          // UGC Safety details (Play Store compliance)
                          _buildUgcSafetyButtons(),
                          const SizedBox(height: 32.0),
                        ],
                      ),
                    ),
                  ),
                ),
    
                // Sticky Bottom CTA Bar
                _buildStickyBottomBar(),
              ],
            ),''';

  var replacementStr = '''            constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : 800),
            child: Column(
              children: [
                // Slide Bar / Drag Handle
                const SizedBox(height: 12.0),
                Center(
                  child: Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.glassBorderColor,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
    
                // Scrollable Content
                Expanded(
                  child: isDesktop 
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Pane (Sticky Photo Carousel)
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 12, 12, 24),
                            child: Column(
                              children: [
                                _buildPhotoCarousel(size),
                                const Spacer(),
                                _buildStickyBottomBar(),
                              ],
                            ),
                          ),
                        ),
                        // Right Pane (Scrollable Info)
                        Expanded(
                          flex: 6,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 24, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeaderSection(),
                                  const SizedBox(height: 24.0),
                                  _buildBentoBlocks(isDesktop),
                                  const SizedBox(height: 24.0),
                                  _buildUgcSafetyButtons(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12.0),
                                  _buildPhotoCarousel(size),
                                  const SizedBox(height: 20.0),
                                  _buildHeaderSection(),
                                  const SizedBox(height: 24.0),
                                  _buildBentoBlocks(isDesktop),
                                  const SizedBox(height: 24.0),
                                  _buildUgcSafetyButtons(),
                                  const SizedBox(height: 32.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _buildStickyBottomBar(),
                      ],
                    ),
                ),
              ],
            ),''';

  content = content.replaceFirst(targetStr, replacementStr);
  file.writeAsStringSync(content);
}
