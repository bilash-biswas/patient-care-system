using System;
using DinkToPdf;
using DinkToPdf.Contracts;
using Moq;
using PatientManagementSystem.Services;
using Xunit;

namespace PatientManagementSystem.Tests.Services
{
    public class PdfGenerationServiceTests
    {
        [Fact]
        public void GenerateInvoicePdf_ValidHtml_ReturnsPdfBytesAndCallsConverter()
        {
            // Arrange
            var mockConverter = new Mock<IConverter>();
            var expectedBytes = new byte[] { 0x25, 0x50, 0x44, 0x46 }; // %PDF
            
            HtmlToPdfDocument? capturedDoc = null;
            mockConverter
                .Setup(c => c.Convert(It.IsAny<HtmlToPdfDocument>()))
                .Callback<IDocument>(doc => capturedDoc = doc as HtmlToPdfDocument)
                .Returns(expectedBytes);

            var service = new PdfGenerationService(mockConverter.Object);
            var html = "<html><body><h1>Invoice</h1></body></html>";

            // Act
            var result = service.GenerateInvoicePdf(html);

            // Assert
            Assert.Equal(expectedBytes, result);
            mockConverter.Verify(c => c.Convert(It.IsAny<HtmlToPdfDocument>()), Times.Once);

            Assert.NotNull(capturedDoc);
            Assert.Equal("Invoice", capturedDoc.GlobalSettings.DocumentTitle);
            Assert.Equal(Orientation.Portrait, capturedDoc.GlobalSettings.Orientation);
            Assert.Equal(PaperKind.A4, capturedDoc.GlobalSettings.PaperSize);
            
            var objSettings = capturedDoc.Objects[0];
            Assert.Equal(html, objSettings.HtmlContent);
            Assert.True(objSettings.PagesCount);
            Assert.Equal("utf-8", objSettings.WebSettings.DefaultEncoding);
        }

        [Fact]
        public void GenerateMedicalRecordPdf_ValidHtml_ReturnsPdfBytesAndCallsConverter()
        {
            // Arrange
            var mockConverter = new Mock<IConverter>();
            var expectedBytes = new byte[] { 0x25, 0x50, 0x44, 0x47 };
            
            HtmlToPdfDocument? capturedDoc = null;
            mockConverter
                .Setup(c => c.Convert(It.IsAny<HtmlToPdfDocument>()))
                .Callback<IDocument>(doc => capturedDoc = doc as HtmlToPdfDocument)
                .Returns(expectedBytes);

            var service = new PdfGenerationService(mockConverter.Object);
            var html = "<html><body><h1>Medical Record</h1></body></html>";

            // Act
            var result = service.GenerateMedicalRecordPdf(html);

            // Assert
            Assert.Equal(expectedBytes, result);
            mockConverter.Verify(c => c.Convert(It.IsAny<HtmlToPdfDocument>()), Times.Once);

            Assert.NotNull(capturedDoc);
            Assert.Equal("Medical Record", capturedDoc.GlobalSettings.DocumentTitle);
            Assert.Equal(Orientation.Portrait, capturedDoc.GlobalSettings.Orientation);
            
            var objSettings = capturedDoc.Objects[0];
            Assert.Equal(html, objSettings.HtmlContent);
        }
    }
}
