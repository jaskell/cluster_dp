#include "iostream"
#include "vector"
#include "math.h"
using namespace std;
int main(int argc, char** argv)
{
  // generate [0..n-1]
  auto seq = [](size_t n) -> std::vector<size_t> {
      std::vector<size_t> v(n);
      for (size_t i=0; i<n; ++i) v[i] = i;
      return v;
  };
  auto index = seq(n);

  // n * n distance matrix
  std::vector<D> dists(n * n);
  for (size_t i=0; i<n-1; ++i) {
      for (size_t j=i+1; j<n; ++j) { dists[i * n + j] = dists[j * n + i] = distf(values[i], values[j]); }
  }
  auto dist = [&](size_t i, size_t j) { return dists[i * n + j]; }

  // calculate rho & delta
  std::vector<size_t> rho(n);
  for (size_t i=0; i<n; ++i) {
      rho[i] = std::count_if(index.begin(), index.end(), [&](size_t j) { return dist(i,j) < dist_cutoff; });
  }

  std::vector<D> delta(n);
  for (size_t i=0; i<n; ++i) {
      auto it = std::min_element_if(index.begin(), index.end(), [&](size_t j, size_t k) { return dist(i,j) < dist(i,k); }, [&](size_t j) { return rho[j] > rho[i]; });
      if (it == index.end())
          it = std::max_element(index.begin(), index.end(), [&](size_t j, size_t k) { return dist(i,j) < dist(i,k); });
      delta[i] = dist(i, *it);
  }

  //...

  // clustering
  auto dindex = seq(n*n);
  std::sort(dindex.begin(), dindex.end(), [&](size_t i, size_t j) { return dists[i] < dists[j]; });
  while (true) {
      auto it = std::find_if(dindex.begin(), dindex.end(), [&](size_t x) {
          size_t i = x / n, j = x % n;
          return (i != j) && ((labels[i] != -1 && labels[j] == -1 && rho[i] > rho[j]) || (labels[i] == -1 && labels[j] != -1 && rho[j] > rho[i]));
      });
      if (it == dindex.end()) break;
      size_t x = *it, i = x / n, j = x % n;
      if (labels[i] != -1) labels[j] = labels[i];
      else labels[i] = labels[j];
  }
}