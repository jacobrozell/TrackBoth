import SwiftUI
import Charts
import UIKit

// MARK: - Chart Export Utility
/// Utility for exporting SwiftUI charts as images (PNG/PDF)
class ChartExportUtility {
    
    // MARK: - Export Formats
    enum ExportFormat: String, CaseIterable {
        case png = "PNG"
        case pdf = "PDF"
        
        var fileExtension: String {
            switch self {
            case .png: return "png"
            case .pdf: return "pdf"
            }
        }
        
        var mimeType: String {
            switch self {
            case .png: return "image/png"
            case .pdf: return "application/pdf"
            }
        }
    }
    
    // MARK: - Export Methods
    
    /// Export a SwiftUI view as an image
    static func exportView<Content: View>(
        _ view: Content,
        format: ExportFormat,
        size: CGSize = CGSize(width: 800, height: 600)
    ) -> Data? {
        logger.info("Starting chart export - Format: \(format), Size: \(size)", category: .ui)
        let startTime = Date()
        
        // Create hosting controller with proper configuration
        let hostingController = UIHostingController(rootView: view.colorScheme(.light))
        hostingController.view.frame = CGRect(origin: .zero, size: size)
        hostingController.view.backgroundColor = UIColor.white
        
        // Ensure proper rendering environment
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Force layout multiple times to ensure proper rendering
        hostingController.view.layoutIfNeeded()
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        
        // Ensure the view has content
        if hostingController.view.bounds.isEmpty {
            logger.error("Chart export failed - view has empty bounds", category: .ui)
            return nil
        }
        
        let result: Data?
        switch format {
        case .png:
            result = exportAsPNG(hostingController.view, size: size)
        case .pdf:
            result = exportAsPDF(hostingController.view, size: size)
        }
        
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("Chart export", duration: duration)
        logger.info("Chart export completed - Format: \(format), Success: \(result != nil)", category: .ui)
        
        if result == nil {
            logger.error("Chart export failed - no data generated for format: \(format)", category: .ui)
        }
        
        return result
    }
    
    /// Export a chart view as an image
    static func exportChart<Content: View>(
        _ chartView: Content,
        format: ExportFormat,
        title: String,
        size: CGSize = CGSize(width: 800, height: 600)
    ) -> Data? {
        let exportView = ChartExportWrapper(
            chartView: chartView,
            title: title
        )
        
        return Self.exportView(exportView, format: format, size: size)
    }
    
    /// Export a SwiftUI view as an image asynchronously
    static func exportViewAsync<Content: View>(
        _ view: Content,
        format: ExportFormat,
        size: CGSize = CGSize(width: 800, height: 600)
    ) async -> Data? {
        return await withCheckedContinuation { continuation in
            // Create hosting controller on main thread
            DispatchQueue.main.async {
                let hostingController = UIHostingController(rootView: view.colorScheme(.light))
                hostingController.view.frame = CGRect(origin: .zero, size: size)
                hostingController.view.backgroundColor = UIColor.white
                hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                
                // Force layout multiple times to ensure proper rendering
                hostingController.view.layoutIfNeeded()
                hostingController.view.setNeedsLayout()
                hostingController.view.layoutIfNeeded()
                
                // Ensure the view has content
                if hostingController.view.bounds.isEmpty {
                    logger.error("Chart export failed - view has empty bounds", category: .ui)
                    continuation.resume(returning: nil)
                    return
                }
                
                // Give the view a moment to fully render
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    let result: Data?
                    switch format {
                    case .png:
                        result = Self.exportAsPNGWithDrawHierarchy(hostingController.view, size: size)
                    case .pdf:
                        // PDF must be done on main thread since it uses drawHierarchy
                        let pdfResult = Self.exportAsPDF(hostingController.view, size: size)
                        continuation.resume(returning: pdfResult)
                        return
                    }
                    
                    continuation.resume(returning: result)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private static func exportAsPNG(_ view: UIView, size: CGSize) -> Data? {
        // Use higher scale for better quality
        let scale: CGFloat = 2.0
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(scaledSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { 
            logger.error("Chart export failed - no graphics context", category: .ui)
            return nil 
        }
        
        // Set background color to white for better visibility
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: scaledSize))
        
        // Use drawHierarchy instead of layer.render for better SwiftUI compatibility
        // and to avoid threading issues
        let success = view.drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: true)
        
        if !success {
            logger.error("Chart export failed - drawHierarchy returned false", category: .ui)
            return nil
        }
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { 
            logger.error("Chart export failed - no image generated", category: .ui)
            return nil 
        }
        
        guard let imageData = image.pngData() else {
            logger.error("Chart export failed - could not convert to PNG data", category: .ui)
            return nil
        }
        
        logger.info("Chart export successful - PNG data size: \(imageData.count) bytes", category: .ui)
        return imageData
    }
    
    private static func exportAsPNGWithDrawHierarchy(_ view: UIView, size: CGSize) -> Data? {
        // Use higher scale for better quality
        let scale: CGFloat = 2.0
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(scaledSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { 
            logger.error("Chart export failed - no graphics context", category: .ui)
            return nil 
        }
        
        // Set background color to white for better visibility
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: scaledSize))
        
        // Use drawHierarchy instead of render - works better with SwiftUI Charts
        let success = view.drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: true)
        
        if !success {
            logger.error("Chart export failed - drawHierarchy returned false", category: .ui)
            return nil
        }
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { 
            logger.error("Chart export failed - no image generated", category: .ui)
            return nil 
        }
        
        guard let imageData = image.pngData() else {
            logger.error("Chart export failed - could not convert to PNG data", category: .ui)
            return nil
        }
        
        logger.info("Chart export successful with drawHierarchy - PNG data size: \(imageData.count) bytes", category: .ui)
        return imageData
    }
    
    private static func exportAsPDF(_ view: UIView, size: CGSize) -> Data? {
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, CGRect(origin: .zero, size: size), nil)
        UIGraphicsBeginPDFPage()
        
        guard let context = UIGraphicsGetCurrentContext() else {
            logger.error("Chart export failed - no PDF graphics context", category: .ui)
            UIGraphicsEndPDFContext()
            return nil
        }
        
        // Set background color to white for better visibility
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Use drawHierarchy instead of layer.render for better SwiftUI compatibility
        // and to avoid threading issues
        let success = view.drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: true)
        
        if !success {
            logger.error("Chart export failed - drawHierarchy returned false for PDF", category: .ui)
            UIGraphicsEndPDFContext()
            return nil
        }
        
        UIGraphicsEndPDFContext()
        
        let pdfDataResult = pdfData as Data
        logger.info("Chart export successful - PDF data size: \(pdfDataResult.count) bytes", category: .ui)
        return pdfDataResult
    }
}

// MARK: - Chart Export Wrapper
/// Wrapper view for chart exports with title and styling
struct ChartExportWrapper<Content: View>: View {
    let chartView: Content
    let title: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding(.horizontal)
            
            // Chart with explicit sizing and forced light color scheme
            chartView
                .frame(height: 400)
                .background(Color.white)
                .colorScheme(.light) // Force light color scheme for export
            
            // Footer
            HStack {
                Text("Generated by QuickLog")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(Date(), style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(width: 800, height: 600)
        .background(Color.white)
        .colorScheme(.light) // Force light color scheme for entire export
    }
}

// MARK: - Chart Export View Modifier
/// View modifier for adding export functionality to charts
struct ChartExportModifier: ViewModifier {
    let chartTitle: String
    let exportFormat: ChartExportUtility.ExportFormat
    @State private var showingExportSheet = false
    @State private var exportData: Data?
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                Button {
                    exportChart()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(8)
            }
            .sheet(isPresented: $showingExportSheet) {
                if let exportData = exportData {
                    ShareSheet(activityItems: [exportData])
                }
            }
    }
    
    private func exportChart() {
        // This function is used by the ChartExportModifier
        // The actual export logic is handled in the individual chart components
        // and the ChartsView where the export buttons are implemented
        print("Chart export requested - handled by individual chart components")
    }
}

// MARK: - View Extension
extension View {
    /// Add export functionality to a chart view
    func chartExportable(
        title: String,
        format: ChartExportUtility.ExportFormat = .png
    ) -> some View {
        self.modifier(ChartExportModifier(chartTitle: title, exportFormat: format))
    }
}
