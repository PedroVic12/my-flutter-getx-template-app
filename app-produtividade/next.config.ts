const nextConfig = {
  // Isso é crucial para que o Next.js transpile os módulos do Ionic/Stencil
  // e lide corretamente com seus exports e imports.
  transpilePackages: [
    '@ionic/react',
    '@ionic/core',
    'ionicons',
    '@stencil/core', // Embora seja uma dependência de @ionic/core, é bom incluir
    '@stencil/react-output-target'
  ],

  // Outras configurações do seu Next.js...
  // Por exemplo, para Next.js 15 com App Router (se for o caso):
  // experimental: {
  //   serverComponentsExternalPackages: ['@ionic/react', '@ionic/core'],
  //   // Caso você use Turbopack em produção (ainda experimental)
  //   // instrumentationHook: true,
  // },

  // Se você estiver tendo problemas de carregamento de assets ou publicPath (menos provável para .entry.js)
  // output: 'standalone', // Se for um build para Docker ou similar


};

module.exports = nextConfig;