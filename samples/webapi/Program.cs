var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.MapGet("/Environment", () =>
{
    return new EnvironmentInfo();
});

// CancellationTokenSource cancellation = new();
// app.Lifetime.ApplicationStopping.Register( () =>
// {
//     cancellation.Cancel();
// });

// This API demonstrates how to use task cancellation
// to support graceful container shutdown via SIGTERM.
// The method itself is an example and not useful.
// app.MapGet("/Delay/{value}", async (int value) =>
// {
//     try
//     {
//         await Task.Delay(value, cancellation.Token);
//     }
//     catch(TaskCanceledException)
//     {
//     }
    
//     return new {Delay = value};
// });

// app.MapHealthChecks("/healthz");

app.Run();
