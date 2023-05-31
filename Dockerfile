FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
COPY src/Container/Container.csproj src/Container/Container.csproj
RUN dotnet restore "src/Container/Container.csproj"
COPY . .
WORKDIR "/src/Container"
RUN dotnet build "Container.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Container.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Container.dll"]
