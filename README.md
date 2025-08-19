# Spring Boot 3.3 + SBOM (CycloneDX) with Java 21 & Gradle

This project is a **production-grade demo** showing how to generate, package, and expose an **SBOM (Software Bill of Materials)** in a Spring Boot **3.3** application using **Java 21** and **Gradle**. It includes extra dependencies so they show up in the SBOM, an Actuator endpoint for runtime access, and tips for CI/CD + containers.

---

## Why SBOM

Think of an SBOM as the **ingredients list** for your application. It tells you _exactly_ which libraries (and versions) are inside your JAR. That transparency is gold for:

- **Security** — scan for known CVEs early and often.
- **Compliance** — verify licenses before you ship.
- **Operations** — understand what’s running in prod, quickly.

Spring Boot 3.3 makes this super simple: it pre-integrates CycloneDX, embeds the SBOM into your JAR, and exposes it over an Actuator endpoint. You get security & compliance visibility with almost zero boilerplate.

---

## What you’ll find here

- **Gradle + Java 21** setup with Spring Boot 3.3.
- **CycloneDX** Gradle plugin configured.
- **Actuator** SBOM endpoint enabled: `/actuator/sbom` and `/actuator/sbom/application`.
- A **sample “additional” SBOM** (pretending to be a JDK SBOM) served from the classpath to demonstrate multiple SBOMs.
- A few **extra dependencies** (Guava, Commons Lang, PostgreSQL, Prometheus registry) so your SBOM isn’t boring.
- A clean `HelloController` just to prove the app boots and responds.

---

## Quick start

Prerequisites:
- **Java 21** installed (`java -version`)
- **Gradle 8+** installed (`gradle -v`) _or use your IDE’s built-in Gradle_

Build & run:

```bash
gradle clean build
java -jar build/libs/sbom-demo-1.0.0.jar
```

Or from your IDE, run the `SbomDemoApplication` class.

---

## SBOM at build-time

The CycloneDX plugin is applied in `build.gradle`. To generate an SBOM during CI or locally:

```bash
gradle cyclonedxBom
```

Artifacts will be created under `build/reports` (and when you package the app, Spring Boot also **embeds** the SBOM inside the fat JAR at:

```
META-INF/sbom/application.cdx.json
```

The JAR’s manifest will advertise the location and format, making tools’ lives easier.

---

## SBOM at runtime (Actuator)

We expose the SBOM via Actuator. With the app running:

```bash
curl http://localhost:8080/actuator/sbom
```

You’ll see a list of available SBOMs and where they come from. For the application’s SBOM:

```bash
curl http://localhost:8080/actuator/sbom/application
```

We also register a **second SBOM** just to show how multiple SBOMs appear. In `application.yml` we point to a classpath resource:

```yaml
management:
  endpoint:
    sbom:
      additional:
        jdk:
          location: "classpath:external/jdk-sample.cdx.json"
          media-type: "application/vnd.cyclonedx+json"
```

Hit it here:

```
/actuator/sbom/jdk
```

In a real deployment you might point at a **file:** path that’s mounted into the container (e.g., an OS or JDK SBOM produced by your base image pipeline).

---

## Dependencies chosen (so your SBOM is interesting)

- `spring-boot-starter-web`
- `spring-boot-starter-actuator`
- `micrometer-registry-prometheus` (observability)
- `commons-lang3`
- `guava`
- `postgresql` (runtime-only driver)

These show up in the CycloneDX output with versions, licenses (when available), and component relationships.

---

## Production-minded tips

**1) CI/CD**  
- Always run `gradle clean build cyclonedxBom` in CI.
- Publish the SBOM to a tool like **Dependency-Track** or **OWASP Dependency-Check**.
- Fail the build on critical CVEs using your scanner’s policies.

**2) Containers**  
- Add your **base image SBOM** (OS packages, JDK) as an “additional SBOM” using a `file:` path.
- Scan the container image with **Trivy** or **Grype** — both understand CycloneDX.

**3) Performance**  
- We enable SBOM **caching** at the Actuator endpoint so it’s not regenerated on every call (`time-to-live: 10m`).

**4) Governance**  
- Use SBOMs to enforce **license policies** (e.g., allow Apache-2.0, flag GPL-3.0).

**5) Drift detection**  
- Track SBOM diffs between releases — unexpected dependency changes are early warning signs.

---

## Endpoints to try

- Health: `GET /actuator/health`
- Prometheus: `GET /actuator/prometheus`
- SBOM index: `GET /actuator/sbom`
- SBOM (application): `GET /actuator/sbom/application`
- SBOM (jdk sample): `GET /actuator/sbom/jdk`
- Demo API: `GET /api/hello`

---

## Notes

- This repo doesn’t include the Gradle Wrapper binaries. If you prefer wrappers, generate them locally:
  ```bash
  gradle wrapper
  ```
- Replace the `external/jdk-sample.cdx.json` file with a real vendor-provided SBOM in your environment.

---


