# .idx/dev.nix - Corregido para incluir Cloud SQL Proxy
{ pkgs, ... }: {
  # Canal de Nixpkgs (cambiado a "unstable" para mayor compatibilidad de paquetes)
  channel = "unstable";

  # Paquetes necesarios para el desarrollo backend con NestJS, pnpm, y GCP
  packages = [
    # --- Entorno Node.js ---
    pkgs.nodejs_20  # Elige la versión LTS o la que necesites
    pkgs.pnpm       # Gestor de paquetes PNPM

    # --- Herramientas de Desarrollo NestJS ---
    # La CLI de NestJS se instalará globalmente a través de pnpm (ver hooks más abajo)

    # --- Google Cloud ---
    pkgs.google-cloud-sdk # CLI de gcloud (para auth, comandos manuales, ADC)

    # --- Base de Datos ---
    pkgs.postgresql       # Cliente psql (para conectar manually a Cloud SQL si es necesario)
    pkgs.cloud-sql-proxy  # <<< DESCOMENTADO: Instala el proxy de Cloud SQL

    # --- Utilidades Generales ---
    pkgs.git        # Control de versiones
    pkgs.jq         # Útil para procesar JSON en la línea de comandos
    # pkgs.docker     # Si necesitas interactuar con Docker directamente
    # pkgs.docker-compose # Si usas Docker Compose
  ];

  # Variables de entorno (ejemplos - ¡NO confirmes secretos aquí!)
  env = {
    NODE_ENV = "development";
    # GCLOUD_PROJECT = "tu-gcp-project-id"; # Útil si es constante
    # Añade otras variables no sensibles que necesites globalmente
  };

  # Configuración de vista previa para ejecutar la app NestJS con PNPM
  idx.previews = {
    enable = true;
    previews = {
      nestjs_app = {
        # Comando para iniciar la aplicación NestJS usando PNPM
        # Ajusta 'start:dev' según tu script en package.json
        command = [ "pnpm" "run" "start:dev" ];
        manager = "web"; # Para APIs HTTP
        # cwd = "."; # Directorio raíz por defecto
      };
    };
  };

  # Extensiones recomendadas de VS Code (Code OSS) para este stack
  idx.extensions = [
    "dbaeumer.vscode-eslint"        # Linting
    "esbenp.prettier-vscode"        # Formateo
    "firsttris.vscode-jest-runner"  # Ejecutor de pruebas Jest
    "ms-azuretools.vscode-docker"   # Soporte para Docker
    "googlecloudtools.cloudcode"    # Integración con Google Cloud
    "prisma.prisma"                 # Si usas Prisma
    "patbenatar.advanced-new-file"  # Útil para crear archivos/carpetas
    "egomobile.vscode-transform"    # Transformaciones de texto útiles
  ];

  # Hooks del ciclo de vida del espacio de trabajo
  idx.workspace = {
    # Se ejecuta cuando el espacio de trabajo se crea por primera vez
    # o cuando se reconstruye después de cambios en dev.nix
    onCreate = {
      # Instala globalmente la CLI de NestJS usando pnpm
      install-nestjs-cli = "pnpm add -g @nestjs/cli";
      # La instalación de dependencias del proyecto (pnpm install) NO se ejecuta aquí.
      # El usuario debe ejecutarla manualmente en el terminal.
    };

    # Se ejecuta cada vez que se inicia el espacio de trabajo
    onStart = {
      # Muestra versiones de herramientas clave (útil para depuración)
      # Nota: 'nest -v' fallará aquí hasta que onCreate se ejecute exitosamente y el workspace se reinicie.
      show-versions = "node -v && pnpm -v && gcloud -v";
      # (Opcional) Autenticación con gcloud si no está ya autenticado
      # check-gcloud-auth = "gcloud auth list || gcloud auth login";
    };
  };
}
