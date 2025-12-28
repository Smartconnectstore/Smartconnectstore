/** @type {import('next').NextConfig} */
const nextConfig = {
  webpack(config) {
    return config
  },
  experimental: {} // disables turbo
}

module.exports = nextConfig
