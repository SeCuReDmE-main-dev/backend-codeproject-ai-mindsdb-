using System;
using System.IO;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace PortraitFilter
{
    class Program
    {
        private static readonly HttpClient client = new HttpClient();
        private static readonly string codeProjectApiUrl = "http://localhost:32168/v1";

        static async Task Main(string[] args)
        {
            Console.WriteLine("Starting PortraitFilter Module");
            Console.WriteLine("This module provides portrait filtering capabilities through CodeProject AI");

            // Listen for commands
            while (true)
            {
                Console.WriteLine("\nOptions:");
                Console.WriteLine("1. Filter portrait from local image");
                Console.WriteLine("2. Detect faces in local image");
                Console.WriteLine("3. Exit");
                Console.Write("Select option (1-3): ");
                
                string choice = Console.ReadLine() ?? "";
                
                if (choice == "3" || choice.ToLower() == "exit")
                    break;
                
                try
                {
                    switch (choice)
                    {
                        case "1":
                            await FilterPortrait();
                            break;
                        case "2":
                            await DetectFaces();
                            break;
                        default:
                            Console.WriteLine("Invalid option. Please try again.");
                            break;
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error: {ex.Message}");
                }
            }
        }

        static async Task FilterPortrait()
        {
            Console.Write("Enter path to image file: ");
            string imagePath = Console.ReadLine() ?? "";
            
            if (!File.Exists(imagePath))
            {
                Console.WriteLine("File not found!");
                return;
            }
            
            Console.Write("Enter output file path: ");
            string outputPath = Console.ReadLine() ?? "";
            
            if (string.IsNullOrWhiteSpace(outputPath))
            {
                outputPath = Path.Combine(
                    Path.GetDirectoryName(imagePath) ?? "",
                    Path.GetFileNameWithoutExtension(imagePath) + "_filtered" + Path.GetExtension(imagePath)
                );
            }
            
            Console.WriteLine("Processing image...");
            
            // Create multipart form data content
            using var formData = new MultipartFormDataContent();
            using var imageContent = new ByteArrayContent(File.ReadAllBytes(imagePath));
            imageContent.Headers.Add("Content-Type", "image/jpeg");
            formData.Add(imageContent, "image", Path.GetFileName(imagePath));
            
            var response = await client.PostAsync($"{codeProjectApiUrl}/vision/portrait", formData);
            response.EnsureSuccessStatusCode();
            
            var responseBytes = await response.Content.ReadAsByteArrayAsync();
            File.WriteAllBytes(outputPath, responseBytes);
            
            Console.WriteLine($"Filtered image saved to: {outputPath}");
        }

        static async Task DetectFaces()
        {
            Console.Write("Enter path to image file: ");
            string imagePath = Console.ReadLine() ?? "";
            
            if (!File.Exists(imagePath))
            {
                Console.WriteLine("File not found!");
                return;
            }
            
            Console.WriteLine("Detecting faces...");
            
            // Create multipart form data content
            using var formData = new MultipartFormDataContent();
            using var imageContent = new ByteArrayContent(File.ReadAllBytes(imagePath));
            imageContent.Headers.Add("Content-Type", "image/jpeg");
            formData.Add(imageContent, "image", Path.GetFileName(imagePath));
            
            var response = await client.PostAsync($"{codeProjectApiUrl}/vision/face", formData);
            response.EnsureSuccessStatusCode();
            
            var responseContent = await response.Content.ReadAsStringAsync();
            var result = JsonSerializer.Deserialize<JsonElement>(responseContent);
            
            // Parse and display face detection results
            if (result.TryGetProperty("predictions", out var predictions))
            {
                int faceCount = predictions.GetArrayLength();
                Console.WriteLine($"Found {faceCount} faces:");
                
                for (int i = 0; i < faceCount; i++)
                {
                    var face = predictions[i];
                    double confidence = face.GetProperty("confidence").GetDouble();
                    var box = face.GetProperty("box");
                    
                    int x = box.GetProperty("x").GetInt32();
                    int y = box.GetProperty("y").GetInt32();
                    int width = box.GetProperty("width").GetInt32();
                    int height = box.GetProperty("height").GetInt32();
                    
                    Console.WriteLine($"Face #{i+1}: Confidence {confidence:F2}, Position: ({x}, {y}), Size: {width}x{height}");
                }
            }
            else
            {
                Console.WriteLine("No faces detected or unexpected response format.");
                Console.WriteLine($"Raw response: {responseContent}");
            }
        }
    }
}