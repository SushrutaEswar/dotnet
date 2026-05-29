var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapGet("/", () => "Blue Green Deployment Working");

app.MapGet("/health", () => Results.Ok("Healthy"));

app.Run("http://0.0.0.0:5000");