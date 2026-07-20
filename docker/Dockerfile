# ==========================================
# Stage 1: Build & Packaging Stage (Maven Builder)
# ==========================================
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder

# Set working directory inside build container
WORKDIR /build

# Copy Maven descriptor first to leverage Docker layer caching for dependencies
COPY application/pom.xml .

# Download dependencies (cached if pom.xml has not changed)
RUN mvn dependency:go-offline -B

# Copy application source code
COPY application/src ./src

# Compile and package application (skipping tests since tests are run prior in CI pipeline)
RUN mvn package -DskipTests -B

# ==========================================
# Stage 2: Runtime Stage (Lightweight JRE Alpine)
# ==========================================
FROM eclipse-temurin:21-jre-alpine AS runner

# Create non-root system group and user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy compiled JAR artifact from Stage 1 Builder
COPY --from=builder /build/target/devops-app-1.0.0-SNAPSHOT.jar app.jar

# Change ownership to non-root user
RUN chown -x /app/app.jar && chown -R appuser:appgroup /app

# Switch to non-root user context
USER appuser

# Expose HTTP application port
EXPOSE 8080

# Configure JVM memory caps suitable for AWS Free Tier 1GB RAM constraint
ENV JAVA_OPTS="-Xms128m -Xmx256m -XX:+UseG1GC"

# Container entrypoint command
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
