import { IsDateString, IsNotEmpty, IsOptional, IsString, Matches } from 'class-validator';

export class CreateBookingDto {
  @IsString()
  @IsNotEmpty()
  serviceId: string;

  @IsDateString()
  date: string; // Format: YYYY-MM-DD

  @IsString()
  @Matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, {
    message: 'startTime must be in HH:mm format (e.g., 10:00)',
  })
  startTime: string;

  @IsString()
  @Matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, {
    message: 'endTime must be in HH:mm format (e.g., 11:00)',
  })
  endTime: string;

  @IsString()
  @IsOptional()
  notes?: string;
}
