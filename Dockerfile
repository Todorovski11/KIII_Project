# Stage 1: Build the application
FROM maven:3.9.6-eclipse-temurin-17 AS build

# Set the working directory inside the build container
WORKDIR /app

# Copy only the pom.xml to cache dependencies during build
COPY pom.xml .

# Download dependencies without building the application
RUN mvn dependency:go-offline

# Copy the source code to the build context
COPY src ./src

# Package the application (skip tests)
RUN mvn clean package -DskipTests

# Optional: List files in the target directory for debugging
RUN ls -la target


# Stage 2: Create the runtime image
FROM amazoncorretto:21-alpine3.15-jdk

# Set the working directory inside the runtime container
WORKDIR /app

# Copy the built jar file from the build stage
# Use wildcard to avoid specifying the exact name
COPY --from=build /app/target/*.jar /app/demo.jar

# Expose the application port (optional)
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "/app/demo.jar"]
