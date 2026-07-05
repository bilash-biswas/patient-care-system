# Build Stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY ["PatientManagementSystem.csproj", "./"]
RUN dotnet restore "PatientManagementSystem.csproj"

# Copy all files and build
COPY . .
RUN dotnet build "PatientManagementSystem.csproj" -c Release -o /app/build

# Publish Stage
FROM build AS publish
RUN dotnet publish "PatientManagementSystem.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Final Runtime Stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Expose port
EXPOSE 8080
EXPOSE 8081

ENTRYPOINT ["dotnet", "PatientManagementSystem.dll"]
