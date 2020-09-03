import http from 'k6/http';
import { sleep } from 'k6';
export default function() {
  http.get('http://blaapp1-demo-dev31.apps.cluster-31fa.31fa.example.opentlc.com/WeatherForecast');
  sleep(1);
}