var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();
builder.Services.AddHealthChecks();
builder.Services.AddResponseCaching();
var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
	app.UseExceptionHandler("/Error");
	// The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
	app.UseHsts();
}

app.UseHealthChecks("/liveness");
app.UseHealthChecks("/readiness");


var facts = new[] { "It is impossible for most people to lick their own elbow", "A crocodile cannot stick its tongue out.", "A shrimp's heart is in its head.", "It is physically impossible for pigs to look up into the sky." };

app.MapGet("/api/cool", () =>
{
	return Results.Ok(facts);
}).CacheOutput();

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();
app.UseResponseCaching();
app.UseAuthorization();

app.MapRazorPages();

app.Run();
