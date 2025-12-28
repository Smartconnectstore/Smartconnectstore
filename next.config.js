/** @type {import('next').NextConfig} */
const nextConfig = {
  webpack: (config) => config,
  experimental: {
    turbo: false, // disable Turbopack
  },
};
module.exports = nextConfig;
