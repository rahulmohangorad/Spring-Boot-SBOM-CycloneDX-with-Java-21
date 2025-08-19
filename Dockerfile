# Example production-ish Dockerfile for Java 21
FROM eclipse-temurin:21-jre-alpine AS runtime

WORKDIR /app
# Copy the fat JAR built by Spring Boot
COPY build/libs/sbom-demo-1.0.0.jar app.jar

# If you mount additional SBOMs, point Actuator to a file path like:
# ENV MANAGEMENT_ENDPOINT_SBOM_ADDITIONAL_OS_LOCATION="file:/sboms/os.cdx.json"
# ENV MANAGEMENT_ENDPOINT_SBOM_ADDITIONAL_OS_MEDIA_TYPE="application/vnd.cyclonedx+json"

EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
