/** @type {import('next').NextConfig} */
const nextConfig = {
  webpack(config) {
    return config
  },
  experimental: {} // disable turbo or any other experimental
}

module.exports = nextConfig
