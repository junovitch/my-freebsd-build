--- src/FbTk/TextButton.cc.orig	2013-06-17 11:38:14 UTC
+++ src/FbTk/TextButton.cc
@@ -143,11 +143,17 @@ void TextButton::drawText(int x_offset, 
     unsigned int textlen = visual.size();
     unsigned int button_width = width();
     unsigned int button_height = height();
+    const int max_width = static_cast<int>(button_width) - x_offset -
+        m_left_padding - m_right_padding;
+
+    if (max_width <= bevel()) {
+        return;
+    }
 
     translateSize(m_orientation, button_width, button_height);
 
     // horizontal alignment, cut off text if needed
-    int align_x = FbTk::doAlignment(button_width - x_offset - m_left_padding - m_right_padding,
+    int align_x = FbTk::doAlignment(max_width,
                                     bevel(), justify(), font(),
                                     visual.data(), visual.size(),
                                     textlen); // return new text len
