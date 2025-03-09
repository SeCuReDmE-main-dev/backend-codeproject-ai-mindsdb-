using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace SentimentAnalysis
{
    class Program
    {
        private static readonly HttpClient client = new HttpClient();
        private static readonly string mindsDbApiUrl = "http://localhost:47334/api/sql/query";
        private static readonly string codeProjectApiUrl = "http://localhost:32168/v1/analyze";

        static async Task Main(string[] args)
        {
            Console.WriteLine("Starting SentimentAnalysis Module");
            Console.WriteLine("This module integrates CodeProject AI with MindsDB for sentiment analysis");

            // Listen for input to analyze
            while (true)
            {
                Console.WriteLine("\nEnter text to analyze sentiment (or 'exit' to quit):");
                string input = Console.ReadLine() ?? "";
                
                if (input.ToLower() == "exit")
                    break;
                
                if (string.IsNullOrWhiteSpace(input))
                    continue;

                try
                {
                    // First analyze with CodeProject AI (if available)
                    try
                    {
                        var codeProjectResult = await AnalyzeWithCodeProjectAI(input);
                        Console.WriteLine($"CodeProject AI Analysis: {codeProjectResult}");
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"CodeProject AI analysis failed: {ex.Message}");
                    }

                    // Then analyze with MindsDB (if available)
                    try
                    {
                        var mindsDbResult = await AnalyzeWithMindsDB(input);
                        Console.WriteLine($"MindsDB Analysis: {mindsDbResult}");
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"MindsDB analysis failed: {ex.Message}");
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error performing analysis: {ex.Message}");
                }
            }
        }

        static async Task<string> AnalyzeWithCodeProjectAI(string text)
        {
            var request = new
            {
                text = text
            };

            var content = new StringContent(
                JsonSerializer.Serialize(request),
                Encoding.UTF8,
                "application/json"
            );

            var response = await client.PostAsync($"{codeProjectApiUrl}/sentiment", content);
            response.EnsureSuccessStatusCode();
            
            var responseContent = await response.Content.ReadAsStringAsync();
            var result = JsonSerializer.Deserialize<JsonElement>(responseContent);
            
            // Extract sentiment from the response
            string sentiment = result.GetProperty("sentiment").GetString() ?? "unknown";
            double score = result.GetProperty("score").GetDouble();
            
            return $"Sentiment: {sentiment}, Score: {score:F2}";
        }

        static async Task<string> AnalyzeWithMindsDB(string text)
        {
            // Create a SQL query for MindsDB
            var sqlQuery = $"SELECT sentiment FROM sentiment_model WHERE text = '{text.Replace("'", "''")}'";
            
            var request = new
            {
                query = sqlQuery
            };

            var content = new StringContent(
                JsonSerializer.Serialize(request),
                Encoding.UTF8,
                "application/json"
            );

            var response = await client.PostAsync(mindsDbApiUrl, content);
            response.EnsureSuccessStatusCode();
            
            var responseContent = await response.Content.ReadAsStringAsync();
            var result = JsonSerializer.Deserialize<JsonElement>(responseContent);
            
            // Extract results from MindsDB response
            string sentiment = "unknown";
            double confidence = 0;
            
            try {
                var columnNames = result.GetProperty("column_names").EnumerateArray();
                var data = result.GetProperty("data").EnumerateArray().First();
                
                int sentimentIndex = -1;
                int confidenceIndex = -1;
                
                // Find the indices for sentiment and confidence columns
                for (int i = 0; i < columnNames.Count(); i++)
                {
                    string colName = columnNames.ElementAt(i).GetString() ?? "";
                    if (colName.ToLower() == "sentiment") sentimentIndex = i;
                    if (colName.ToLower() == "confidence") confidenceIndex = i;
                }
                
                if (sentimentIndex >= 0)
                    sentiment = data[sentimentIndex].GetString() ?? "unknown";
                    
                if (confidenceIndex >= 0)
                    confidence = data[confidenceIndex].GetDouble();
            }
            catch {
                // If we can't parse the response as expected, return a generic response
                return $"Result: {responseContent}";
            }
            
            return $"Sentiment: {sentiment}, Confidence: {confidence:F2}";
        }
    }
}